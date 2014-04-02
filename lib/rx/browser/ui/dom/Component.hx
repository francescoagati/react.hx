package rx.browser.ui.dom;

class Component extends rx.core.ContainerComponent {
  var tagOpen: String;
  var tagClose: String;
  var omitClose: Bool;
  public function new(tagName: String, omitClose: Bool, descriptor: rx.core.Descriptor) {
    super(descriptor);
    this.tagOpen = '<$tagName';
    this.tagClose = omitClose ? '' : '</$tagName>';
  }

  public override function mountComponent(rootId: String, transaction: rx.browser.ReconcileTransaction, mountDepth: Int):String {
    super.mountComponent(rootId, transaction, mountDepth);
    return (
      createOpenTagMarkupAndPutListeners(transaction) +
      createContentMarkup(transaction) +
      tagClose
    );
  }

  public function createOpenTagMarkupAndPutListeners(transaction: rx.browser.ReconcileTransaction):String {
    var props = this.props;
    var ret = this.tagOpen;
    if (props != null) {
      for (propKey in props.keys()) {
        
        var propValue = props.get(propKey);

        if (propValue == null) {
          continue;
        }

        if (false) {
          // putListener(this._rootNodeID, propKey, propValue, transaction);
        } else {
          // if (propKey == STYLE) {
          //   if (propValue != null) {
          //     propValue = props.style = rx.core.Tools.merge(props.style, null);
          //   }
          //   propValue = CSSPropertyOperations.createMarkupForStyles(propValue);
          // }
          var markup = PropertyOperations.createMarkupForProperty(propKey, propValue);
          if (markup) {
            ret += ' ' + markup;
          }
        }
      }
    }

    if (transaction.renderToStaticMarkup) {
      return ret + '>';
    }

    var markupForId = PropertyOperations.createMarkupForId(rootNodeId);
    return ret + ' ' + markupForId + '>';
  }

  public function createContentMarkup(transaction: rx.browser.ReconcileTransaction) {
    var mountImages = this.mountChildren(this.children,transaction);
    return mountImages.join('');
  }
}