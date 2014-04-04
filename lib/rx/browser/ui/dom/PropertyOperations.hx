package rx.browser.ui.dom;

import rx.browser.ui.dom.Property;

class PropertyOperations {

  public static inline function escapeTextForBrowser(text:String):String {
    trace('escapeTextForBrowser($text)');
    return text;
  }

  public static inline function processAttributeNameAndPrefix(name:String):String {
    trace('processAttributeNameAndPrefix($name)');
    return escapeTextForBrowser(name) + '="';
  }

  public static inline function createMarkupForId(id:String):String {
    return processAttributeNameAndPrefix(rx.browser.ui.dom.Property.ID_ATTRIBUTE_NAME) + escapeTextForBrowser(id) + '"';
  }

  public static function createMarkupForProperty(name: String, value:String):String {
    trace('createMarkupForProperty($name, $value)');
    if (Property.isStandardName(name)) {
      if (shouldIgnoreValue(name, value)) {
        return '';
      }
      var attributeName = Property.getAttributeName(name);
      if (Property.hasBooleanValue(name)) {
        return escapeTextForBrowser(attributeName);
      }
      return processAttributeNameAndPrefix(attributeName) + escapeTextForBrowser(value) + '"';
    } else if (Property.isCustomAttribute(name)) {
      if (value == null) {
        return '';
      }
      return processAttributeNameAndPrefix(name) +
        escapeTextForBrowser(value) + '"';
    } else if (/*__DEV__*/false) {
      throw 'warnUnknownProperty($name)';
    }
    return null;
  }

  private static function shouldIgnoreValue(name: String, value: Dynamic) {
    trace('shouldIgnoreValue($name, $value)');
    return value == null ||
      (Property.hasBooleanValue(name) && !value) ||
      (Property.hasPositiveNumbericValue(name) && (Math.isNaN(value) || value < 1));
  }

  public static function setValueForProperty(node: js.html.Element, name: String, value: Dynamic) {
    trace('setValueForProperty($name, $value)');
    if (Property.isStandardName(name)) {
      var mutationMethod = Property.getMutationMethod(name);
      if (mutationMethod != null) {
        mutationMethod(node, value);
      } else if (shouldIgnoreValue(name, value)) {
        deleteValueForProperty(node, name);
      } else if (Property.mustUseAttributeName(name)) {
        node.setAttribute(Property.getAttributeName(name), value);
      } else {
        var propName = Property.getPropertyName(name);
        if (Property.hasSideEffects(name) || Reflect.field(node, propName) != value) {
          Reflect.setField(node, propName, value);
        }
      }
    } else if (Property.isCustomAttribute(name)) {
      if (value == null) {
        node.removeAttribute(Property.getAttributeName(name));
      } else {
        node.setAttribute(name, value);
      }
    }
  }

  public static function deleteValueForProperty(node: js.html.Element, name: String) {
    if (Property.isStandardName(name)) {
      var mutationMethod = Property.getMutationMethod(name);
      if (mutationMethod != null) {
        mutationMethod(node, null);
      } else if (Property.mustUseAttributeName(name)) {
        node.removeAttribute(Property.getAttributeName(name));
      } else {
        var propName = Property.getAttributeName(name);
        var defaultValue = Property.getDefaultValueForProperty(node.nodeName, name);
        if (!Property.hasSideEffects(name) || Reflect.field(node, propName) != defaultValue) {
          Reflect.setField(node, propName, defaultValue);
        }
      }
    } else if (Property.isCustomAttribute(name)) {
      node.removeAttribute(name);
    } else if (/*__DEV__*/false) {
      throw 'warnUnknownProperty: $name';
    }
  }
}