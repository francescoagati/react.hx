package rx.core;

enum UpdateTypes {
  InsertMarkup;
  MoveExisting;
  RemoveNode;
  TextContent;
}

class ContainerComponent extends rx.core.Component {
  public static var updateDepth:Int = 0;
  var rendererChildren: Map<String, rx.core.Component>;
  public function mountChildren(nestedChildren:Array<rx.core.Component>, transaction:rx.browser.ReconcileTransaction) {
    var children:Map<String, rx.core.Component> = rx.utils.FlattenChildren.flattenChildren(nestedChildren);
    var mountImages = [];
    var index = 0;
    rendererChildren = children;
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

  public static var updateQueue: Array<js.html.Node> = new Array<js.html.Node>();
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

  public function updateChildren(nextNestedChildren: Array<rx.core.Component>, transaction: rx.browser.ReconcileTransaction) {
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

  public function _updateChildren(nextNestedChildren: Array<rx.core.Component>, transaction: rx.browser.ReconcileTransaction) {
    var nextChildren = rx.utils.FlattenChildren.flattenChildren(nextNestedChildren);
    var prevChildren = this.rendererChildren;

    if ((nextChildren == null) && (rendererChildren == null)) {
      return;
    } 
    for (name in nextChildren.keys()) {
      var prevChild = null;
      if (prevChildren != null) {
        prevChild = prevChildren.get(name);
      }
      var nextChild = nextChildren.get(name);
      if (rx.core.Component.shouldUpdate(prevChild, nextChild)) {
        prevChild.receiveComponent(nextChild, transaction);
      }
    }
  }

  public function unmountChildren() {
    trace('ContainerComponent.unmountChildren');
  }

  public function moveChild(child: rx.core.Component, toIndex: Int, lastIndex: Int) {
    trace('ContainerComponent.moveChild');
  }

  public function createChild(child: rx.core.Component, mountImage: String) {
    trace('ContainerComponent.createChild');
  }

  public function removeChild(child: rx.core.Component) {
    trace('ContainerComponent.removeChild');
  }

  public function setTextContent(content: String) {
    trace('ContainerComponent.setTextContent');
  }



}