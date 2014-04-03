package rx.browser.ui.dom;

class Danger {

  public static var dummyNode = js.Browser.document.createElement('div');
  public static function createNodesFromMarkup(markup: String, handleScript: Dynamic) {
    var node = dummyNode;
    return [];
  }

  private static function getNodeName(markup:String):String {
    return markup.substring(1, markup.indexOf(' '));
  }

  public static function dangerouslyRenderMarkup(markupList: Array<String>):Array<js.html.Node> {
    return new Array<js.html.Node>();
  }

  public static function dangerouslyReplaceNodeWithMarkup(oldChild: js.html.Node, markup: String) {
    var newChild = createNodesFromMarkup(markup, function () {})[0];
    oldChild.parentNode.replaceChild(newChild, oldChild);
  }


}