package rx.core;

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
  }

  public function updateChildren(nextNestedChildren: rx.core.Component, transaction) {

  }

  public function unmountChildren() {

  }

  public function moveChild(child: rx.core.Component, toIndex: Int, lastIndex: Int) {

  }

  public function createChild(child: rx.core.Component, mountImage: String) {

  }

  public function removeChild(child: rx.core.Component) {

  }

  public function setTextContent(content: String) {

  }



}