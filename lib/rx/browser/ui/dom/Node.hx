package rx.browser.ui.dom;

class Node {
  public inline static function containsNode(outerNode:js.html.Node, innerNode:js.html.Node):Bool {
    if (outerNode == null || innerNode == null)  return false;
    else if (outerNode == innerNode) return true;
    else if (isTextNode(outerNode)) return false;
    else if (isTextNode(innerNode)) return containsNode(outerNode, innerNode.parentNode);
    else if (outerNode.contains != null) return outerNode.contains(innerNode);
    else if (outerNode.compareDocumentPosition != null) return (outerNode.compareDocumentPosition(innerNode) & 16) != 0;
    else return false;
  }

  public static function isTextNode(node:js.html.Node):Bool {
    return node.nodeType == 3;
  }
}
