package rx.browser.ui.dom.components;

class Text extends rx.core.Component {
  var text: String;
  public inline function new(text: String, descriptor: rx.core.Descriptor) {
    super(descriptor);
    this.text = text;
  }

  public inline override function mountComponent(rootId: String, transaction: rx.browser.ReconcileTransaction, mountDepth: Int):String {
    super.mountComponent(rootId, transaction, mountDepth);

    var id = rx.browser.ui.dom.PropertyOperations.createMarkupForId(rootId);
    return '<span $id>$text</span>';
  }

  public inline override function receiveComponent(nextComponent:rx.core.Component, transaction:rx.browser.ReconcileTransaction) {
    var next:Text = cast nextComponent;
    var nextText = next.text;
    if (nextText != this.text) {
      this.text = nextText;
      rx.browser.ui.dom.IdOperations.updateTextContentById(
        this.rootNodeId,
        nextText
      );
    }
  }
}
