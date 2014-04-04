package rx.core;

import rx.core.Component;
import rx.browser.ReconcileTransaction;
import rx.utils.FlattenChildren;

enum UpdateTypes {
  InsertMarkup;
  MoveExisting;
  RemoveNode;
  TextContent;
}

class ContainerComponent extends Component {
  public static var updateDepth:Int = 0;
  var renderedChildren: Map<String, Component>;
  public function mountChildren(nestedChildren:Array<Component>, transaction:ReconcileTransaction) {
    var children:Map<String, Component> = FlattenChildren.flattenChildren(nestedChildren);
    var mountImages = [];
    var index = 0;
    renderedChildren = children;
    for (key in children.keys()) {
      var child = children.get(key);
      var rootId = this.rootNodeId + key;
      var mountImage = child.mountComponent(rootId, transaction, this.mountDepth + 1);
      mountImages.push(mountImage);
      child.mountIndex = index;
      index++;
    }
    return mountImages;
  }

  public function updateTextContent(content: String) {
    ContainerComponent.updateDepth++;
    trace('ContainerComponent.updateTextContent');
  }

  public static var updateQueue: Array<Dynamic> = new Array<Dynamic>();
  public static var markupQueue: Array<String> = new Array<String>();
  public static function processQueue() {
    if (updateQueue.length > 0) {
      rx.browser.ui.dom.IdOperations.dangerouslyProcessChildrenUpdates(
        updateQueue,
        markupQueue
      );
      clearQueue();
    }
  }

  public static function clearQueue() {
    updateQueue.splice(0, updateQueue.length);
    markupQueue.splice(0, markupQueue.length);
  }

  public function updateChildren(nextNestedChildren: Array<Component>, transaction: ReconcileTransaction) {
    updateDepth++;
    var errorThrown = true;
    try {
      this._updateChildren(nextNestedChildren, transaction);
      errorThrown = false;
    } catch(e:js.Error) {
      trace(e.stack);
    }

    updateDepth--;
    if (updateDepth == 0) {
      errorThrown ? clearQueue() : processQueue();
    }

  }

  public function _updateChildren(nextNestedChildren: Array<Component>, transaction: ReconcileTransaction) {
    var nextChildren = FlattenChildren.flattenChildren(nextNestedChildren);
    var prevChildren = this.renderedChildren;

    if ((nextChildren == null) && (renderedChildren == null)) {
      return;
    }

    var lastIndex = 0;
    var nextIndex = 0;

    for (name in nextChildren.keys()) {
      var prevChild = null;
      if (prevChildren != null) {
        prevChild = prevChildren.get(name);
      }

      var nextChild = nextChildren.get(name);

      if (Component.shouldUpdate(prevChild, nextChild)) {
        this.moveChild(prevChild, nextIndex, lastIndex);
        lastIndex = Std.int(Math.max(prevChild.mountIndex, lastIndex));
        prevChild.receiveComponent(nextChild, transaction);
        prevChild.mountIndex = nextIndex;
      } else {
        if (prevChild != null) {
          lastIndex = Std.int(Math.max(prevChild.mountIndex, lastIndex));
          this.unmountChildByName(prevChild, name);
        }
        this.mountChildByNameAtIndex(nextChild, name, nextIndex, transaction);
      }

      nextIndex++;
    }

    for (name in prevChildren.keys()) {
      var prevChild = prevChildren.get(name);
      if (prevChild != null && nextChildren != null && !nextChildren.exists(name)) {
        this.unmountChildByName(prevChildren.get(name), name);
      }
    }

  }

  private function enqueueMarkup(parentId: String, markup: String, toIndex: Int) {
    updateQueue.push({
      parentId: parentId,
      parentNode: null,
      type: UpdateTypes.InsertMarkup,
      markupIndex: markupQueue.push(markup) - 1,
      textContent: null,
      fromIndex: null,
      toIndex: toIndex
    });
  }

  public function unmountChildren() {
    trace('ContainerComponent.unmountChildren');
  }

  public function moveChild(child: Component, toIndex: Int, lastIndex: Int) {
    //trace('ContainerComponent.moveChild');
  }

  public function createChild(child: Component, mountImage: String) {
    enqueueMarkup(this.rootNodeId, mountImage, child.mountIndex);
  }

  public function removeChild(child: Component) {
    trace('ContainerComponent.removeChild');
  }

  public function setTextContent(content: String) {
    trace('ContainerComponent.setTextContent');
  }

  public function mountChildByNameAtIndex(child: Component, name: String, index: Int, transaction: ReconcileTransaction) {

    var rootId = this.rootNodeId + name;
    var mountImage = child.mountComponent(
      rootId,
      transaction,
      this.mountDepth + 1
    );
    child.mountIndex = index;
    this.createChild(child, mountImage);
    if(renderedChildren == null) this.renderedChildren = new Map<String, Component>();
    renderedChildren.set(name, child);

  }

  public function unmountChildByName(child: Component, name: String) {
    // TODO: When is this not true?
    // if (ReactComponent.isValidComponent(child)) {
    //   this.removeChild(child);
    //   child._mountIndex = null;
    //   child.unmountComponent();
    //   delete this._renderedChildren[name];
    // }
    trace('unmountChildByName(..., $name)');
  }


}