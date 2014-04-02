package rx.browser.ui.dom.components;

class Text extends rx.core.Component {
  var text: String;
  public function new(text: String, descriptor: rx.core.Descriptor) {
    super(descriptor);
    this.text = text;
  }

  public override function mountComponent(rootId: String, transaction: rx.browser.ReconcileTransaction, mountDepth: Int):String {
    super.mountComponent(rootId, transaction, mountDepth);

    var id = rx.browser.ui.dom.PropertyOperations.createMarkupForId(rootId);
    return '<span $id>$text</span>';
  }
}