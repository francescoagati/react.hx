package rx.browser.ui.dom;

import rx.core.ContainerComponent.UpdateTypes;

class ChildrenOperations {

  private inline static function insertChildAt(parentNode: js.html.Node, childNode: js.html.Node, index: Int) {
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

  public inline static function updateTextContent(node: js.html.Node, text: String) {
    node.textContent = text;
  }


  // ### Public

  public inline static function processUpdates(updates: Array<Dynamic>, markupList: Array<String>) {
    var initialChildren: rx.core.Props = null;
    var updatedChildren = null;

    for (update in updates) {
      if (update.type == UpdateTypes.MoveExisting || update.type == UpdateTypes.RemoveNode) {
        var updatedIndex = update.fromIndex;
        var updatedChild = update.parentNode.childNodes[updatedIndex];
        var parentId = update.parentId;

        if (initialChildren == null) initialChildren = {};
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
        if (child != null && child.parentNode != null)
          child.parentNode.removeChild(child);
      }
    }

    for (update in updates) {
      if (update.type == UpdateTypes.InsertMarkup)
        insertChildAt(update.parentNode, renderedMarkup[update.markupIndex], update.toIndex);
      else if(update.type == UpdateTypes.MoveExisting)
        insertChildAt(update.parentNode, initialChildren.get(update.parentId)[update.fromIndex], update.toIndex);
      else if(update.type == UpdateTypes.TextContent)
        updateTextContent(update.parentNode, update.textContent);
      else if (update.type == UpdateTypes.RemoveNode) {}
    }
  }

}
