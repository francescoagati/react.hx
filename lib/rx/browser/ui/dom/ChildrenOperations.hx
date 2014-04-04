package rx.browser.ui.dom;

import rx.core.ContainerComponent.UpdateTypes;

class ChildrenOperations {

  private static function insertChildAt(parentNode: js.html.Node, childNode: js.html.Node, index: Int) {
    var childNodes = parentNode.childNodes;
    if (childNodes[index] == childNode) {
      return;
    }
    if (childNode.parentNode == parentNode) {
      parentNode.removeChild(childNode);
    }
    if (index >= childNodes.length) {
      parentNode.appendChild(childNode);
    } else {
      parentNode.insertBefore(childNode, childNodes[index]);
    }
  }

  public static function updateTextContent(node: js.html.Node, text: String) {
    node.textContent = text;
  }


  // ### Public

  public static function processUpdates(updates: Array<Dynamic>, markupList: Array<String>) {
    
    var initialChildren: Map<String, Array<js.html.Node>> = null;
    var updatedChildren = null;
    for (update in updates) {
      if (update.type == UpdateTypes.MoveExisting || update.type == UpdateTypes.RemoveNode) {
        var updatedIndex = update.fromIndex;
        var updatedChild = update.parentNode.childNodes[updatedIndex];
        var parentId = update.parentId;

        if (initialChildren == null) initialChildren = new Map<String, Array<js.html.Node>>();
        if (updatedChildren == null) updatedChildren = new Array<js.html.Node>();
        updatedChildren.push(updatedChild);
        if (!initialChildren.exists(parentId) || initialChildren.get(parentId) == null) {
          initialChildren.set(parentId, new Array<js.html.Node>());
        }
        var arr = initialChildren.get(parentId);
        arr[updatedIndex] = updatedChild;

        updatedChildren.push(updatedChild);
      }
    }

    var renderedMarkup = Danger.dangerouslyRenderMarkup(markupList);

    if (updatedChildren != null && updatedChildren.length > 0) {
      for (child in updatedChildren) {
        child.parentNode.removeChild(child);
      }
    }

    for (update in updates) {
      switch (update.type) {
        case UpdateTypes.InsertMarkup:
          insertChildAt(update.parentNode, renderedMarkup[update.markupIndex], update.toIndex);
          break;
        case UpdateTypes.MoveExisting:
          insertChildAt(update.parentNode, initialChildren.get(update.parentId)[update.fromIndex], update.toIndex);
          break;
        case UpdateTypes.TextContent:
          updateTextContent(update.parentNode, update.textContent);
          break;
        case UpdateTypes.RemoveNode:
          // already removed
          break;
      }
    }
  }

}
