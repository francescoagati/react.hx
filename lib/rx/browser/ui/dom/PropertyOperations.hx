package rx.browser.ui.dom;

class PropertyOperations {

  public static inline function escapeTextForBrowser(name:String):String {
    return name;
  }

  public static inline function processAttributeNameAndPrefix(name:String):String {
    return escapeTextForBrowser(name) + '="';
  }

  public static inline function createMarkupForId(id:String):String {
    return processAttributeNameAndPrefix(rx.browser.ui.dom.Property.ID_ATTRIBUTE_NAME) + escapeTextForBrowser(id) + '"';
  }

  public static inline function createMarkupForProperty(name: String, value:String) {
    /*
    if (DOMProperty.isStandardName[name]) {
      if (shouldIgnoreValue(name, value)) {
        return '';
      }
      var attributeName = DOMProperty.getAttributeName[name];
      if (DOMProperty.hasBooleanValue[name]) {
        return escapeTextForBrowser(attributeName);
      }
      return processAttributeNameAndPrefix(attributeName) +
        escapeTextForBrowser(value) + '"';
    } else if (DOMProperty.isCustomAttribute(name)) {
      if (value == null) {
        return '';
      }
      return processAttributeNameAndPrefix(name) +
        escapeTextForBrowser(value) + '"';
    } else if (__DEV__) {
      warnUnknownProperty(name);
    }
    return null;
    */
    return null;
  }

}