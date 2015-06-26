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
  var renderedChildren: rx.core.Props;
  public inline function mountChildren(nestedChildren:Array<Component>, transaction:ReconcileTransaction) {
    var children:Props = FlattenChildren.flattenChildren(nestedChildren);
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

  public inline function updateTextContent(content: String) {
    ContainerComponent.updateDepth++;
    trace('ContainerComponent.updateTextContent');
  }

  public static var updateQueue: Array<Dynamic> = new Array<Dynamic>();
  public static var markupQueue: Array<String> = new Array<String>();
  public inline static function processQueue() {
    if (updateQueue.length > 0) {
      rx.browser.ui.dom.IdOperations.dangerouslyProcessChildrenUpdates(
        updateQueue,
        markupQueue
      );
      clearQueue();
    }
  }

  public inline static function clearQueue() {
    updateQueue.splice(0, updateQueue.length);
    markupQueue.splice(0, markupQueue.length);
  }

  public inline function updateChildren(nextNestedChildren: Array<Component>, transaction: ReconcileTransaction) {
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

  public inline function _updateChildren(nextNestedChildren: Array<Component>, transaction: ReconcileTransaction) {
    var nextChildren:Props = FlattenChildren.flattenChildren(nextNestedChildren);
    var prevChildren = this.renderedChildren;

    if ((nextChildren == null) && (renderedChildren == null)) {
      return;
    }

    var lastIndex = 0;
    var nextIndex = 0;

    for (name in nextChildren.keys()) {
      var prevChild:rx.core.Component = null;
      if (prevChildren != null) {
        prevChild = prevChildren.get(name);
      }

      var nextChild:rx.core.Component = nextChildren.get(name);

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

  private inline function enqueueMarkup(parentId: String, markup: String, toIndex: Int) {
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

  public inline function enqueueRemove(parentId: String, fromIndex: Int) {
    // NOTE: Null values reduce hidden classes.
    updateQueue.push({
      parentId: parentId,
      parentNode: null,
      type: UpdateTypes.RemoveNode,
      markupIndex: null,
      textContent: null,
      fromIndex: fromIndex,
      toIndex: null
    });
  }

  public inline function enqueueMove(parentId: String, fromIndex: Int, toIndex: Int) {
    // NOTE: Null values reduce hidden classes.
    updateQueue.push({
      parentId: parentId,
      parentNode: null,
      type: UpdateTypes.MoveExisting,
      markupIndex: null,
      textContent: null,
      fromIndex: fromIndex,
      toIndex: toIndex
    });
  }

  public inline function unmountChildren() {
    trace('ContainerComponent.unmountChildren');
    var renderedChildren = this.renderedChildren;
    for (name in renderedChildren.keys()) {
      var renderedChild = renderedChildren.get(name);
      renderedChild.unmountComponent();
    }
    this.renderedChildren = null;
  }

  public inline function moveChild(child: Component, toIndex: Int, lastIndex: Int) {
    if (child.mountIndex < lastIndex) {
      enqueueMove(this.rootNodeId, child.mountIndex, toIndex);
    }
  }

  public  inline function createChild(child: Component, mountImage: String) {
    enqueueMarkup(this.rootNodeId, mountImage, child.mountIndex);
  }

  public inline function removeChild(child: Component) {
    enqueueRemove(this.rootNodeId, child.mountIndex);
  }

  public inline function setTextContent(content: String) {
    trace('ContainerComponent.setTextContent');
  }

  public inline function mountChildByNameAtIndex(child: Component, name: String, index: Int, transaction: ReconcileTransaction) {

    var rootId = this.rootNodeId + name;
    var mountImage = child.mountComponent(
      rootId,
      transaction,
      this.mountDepth + 1
    );
    child.mountIndex = index;
    this.createChild(child, mountImage);
    if(renderedChildren == null) this.renderedChildren = {};
    renderedChildren.set(name, child);

  }

  public inline function unmountChildByName(child: Component, name: String) {
    this.removeChild(child);
    child.mountIndex = null;
    child.unmountComponent();
    this.renderedChildren.remove(name);
  }


}
