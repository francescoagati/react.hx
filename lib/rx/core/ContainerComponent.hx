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

  public static var updateQueue: Array<Dynamic> = new Array<Dynamic>();
  public static var markupQueue: Array<Dynamic> = new Array<Dynamic>();
  public static function processQueue() {
    if (updateQueue.length > 0) {
      // ReactComponent.BackendIDOperations.dangerouslyProcessChildrenUpdates(
      //   updateQueue,
      //   markupQueue
      // );
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
    } catch(e:Dynamic) {}

    updateDepth--;
    if (updateDepth == 0) {
      errorThrown ? clearQueue() : processQueue();
    }
    
  }

  public function _updateChildren(nextNestedChildren: Array<rx.core.Component>, transaction: rx.browser.ReconcileTransaction) {
    for (child in nextNestedChildren) {
      if (rx.core.Component.shouldUpdate(child, child)) {
        child.receiveComponent(child, transaction);
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