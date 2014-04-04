package rx.browser.ui.dom;

import rx.browser.ui.Mount;
import rx.browser.ui.dom.PropertyOperations;
import rx.browser.ui.dom.ChildrenOperations;
import rx.browser.ui.dom.Danger;

class IdOperations {

  public static inline function updatePropertyById(id: String, name: String, value: Dynamic) {
    var node = Mount.getNode(id);

    if (value != null) {
      PropertyOperations.setValueForProperty(cast node, name, value);
    } else {
      PropertyOperations.deleteValueForProperty(cast node, name);
    }
  }

  public static inline function deletePropertyById(id: String, name: String) {
    var node = Mount.getNode(id);
    PropertyOperations.deleteValueForProperty(cast node, name);
  }

  public static inline function updateStylesById(id: String, styles: Dynamic) {
    var node = Mount.getNode(id);
    rx.browser.ui.css.PropertyOperations.setValuesForStyles(cast node, styles);
  }

  public static inline var useWhitespaceWorkaround: Bool = null;
  public static inline function updateInnerHTMLById(id: String, html: String) {

    var node:js.html.Element = cast Mount.getNode(id);

    // No IE8 =^.^=
    node.innerHTML = html;

  }

  public static inline function updateTextContentById(id: String, content: String) {
    var node = Mount.getNode(id);
    ChildrenOperations.updateTextContent(node, content);
  }

  public static inline function dangerouslyReplaceNodeWithMarkupById(id: String, markup: String) {
    var node = Mount.getNode(id);
    Danger.dangerouslyReplaceNodeWithMarkup(node, markup);
  }

  public static inline function dangerouslyProcessChildrenUpdates(updates: Array<Dynamic>, markup: Array<String>) {
    for (update in updates) {
      update.parentNode = Mount.getNode(update.parentId);
    }
    ChildrenOperations.processUpdates(updates, markup);
  }

}