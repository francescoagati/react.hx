package rx.browser.ui.dom;

class Danger {

  static var OPEN_TAG_NAME_EXP = ~/^(<[^ \/>]+)/;
  static var RESULT_INDEX_ATTR = 'data-danger-index';

  public static function createArrayFrom(obj:js.html.NodeList):Array<js.html.Node> {
    var res = [];
    for (i in obj) {
      res.push(i);
    }
    return res;
  }

  public static var dummyNode = js.Browser.document.createElement('div');
  public static function createNodesFromMarkup(markup: String, handleScript: Dynamic) {
    var node = dummyNode;
    var nodeName = getNodeName(markup);

    var wrap = null;
    if (nodeName != null) wrap = getMarkupWrap(nodeName);
    if (wrap != null) {
      node.innerHTML = wrap[1] + markup + wrap[2];

      var wrapDepth = wrap[0];
      while (wrapDepth-- > 0) {
        node = cast node.lastChild;
      }
    } else {
      node.innerHTML = markup;
    }

    // var scripts = node.getElementsByTagName('script');
    // if (scripts.length) {
    //   createArrayFrom(scripts).forEach(handleScript);
    // }

    var nodes = createArrayFrom(node.childNodes);
    while (node.lastChild != null) {
      node.removeChild(node.lastChild);
    }
    return nodes;
  }

  private static function getNodeName(markup:String):String {
    return markup.substring(1, markup.indexOf(' '));
  }

  private static function getMarkupWrap(name: String):Array<Dynamic> {
    return null;
  }

  public static function dangerouslyRenderMarkup(markupList: Array<String>):Array<js.html.Node> {
    var nodeName = null;
    var markupByNodeName = new Map<String, Array<String>>();

    for (i in 0...markupList.length) {
      nodeName = getNodeName(markupList[i]);
      nodeName = (getMarkupWrap(nodeName) != null) ? nodeName : '*';
      if (!markupByNodeName.exists(nodeName)) markupByNodeName.set(nodeName,[]);
      markupByNodeName.get(nodeName)[i] = markupList[i];
    }
    var resultList = [];
    var resultListAssignmentCount = 0;
    
    for (nodeName in markupByNodeName.keys()) {
      var markupListByNodeName = markupByNodeName.get(nodeName);

      for (resultIndex in 0...markupListByNodeName.length) {
        var markup = markupListByNodeName[resultIndex];
        markupListByNodeName[resultIndex] = OPEN_TAG_NAME_EXP.replace(markup, '$1 ' + RESULT_INDEX_ATTR + '="' + resultIndex + '" ');
      }
      
      // Render each group of markup with similar wrapping `nodeName`.
      var renderNodes:Array<js.html.Element> = cast createNodesFromMarkup(
        markupListByNodeName.join(''),
        function () {} // Do nothing special with <script> tags.
      );
      
      for (i in 0...renderNodes.length) {
        var renderNode = renderNodes[i];
        if (renderNode.hasAttribute != null &&
            renderNode.hasAttribute(RESULT_INDEX_ATTR)) {

          var resultIndex = Std.parseInt(renderNode.getAttribute(RESULT_INDEX_ATTR));
          renderNode.removeAttribute(RESULT_INDEX_ATTR);

          resultList[resultIndex] = renderNode;
          resultListAssignmentCount += 1;

        }
      }
    }

    return cast resultList;

  }

  public static function dangerouslyReplaceNodeWithMarkup(oldChild: js.html.Node, markup: String) {
    var newChild = createNodesFromMarkup(markup, function () {})[0];
    oldChild.parentNode.replaceChild(newChild, oldChild);
  }


}