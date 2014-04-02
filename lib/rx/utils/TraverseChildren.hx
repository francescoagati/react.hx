package rx.utils;

class TraverseChildren {

  static var userProvidedKeyEscaperLookup: Map<String, String> = [
    '='=> '=0',
    '.'=> '=1',
    ':'=> '=2'
  ];

  static var userProvidedKeyEscapeRegex:EReg = ~/[=.:]/g;

  public static inline function userProvidedKeyEscaper(match) {
    return userProvidedKeyEscaperLookup.get(match);
  }

  public static inline function escapeUserProvidedKey(text:String) {
    return userProvidedKeyEscapeRegex.replace(text, '=0');
  }

  public static inline function wrapUserProvidedKey(key:String) {
    return "$" + escapeUserProvidedKey(key);
  }

  public static inline function getComponentKey(component:rx.core.Component, index:Int) {
    if (component != null && component.props != null && component.props.get('key') != null) {
      return wrapUserProvidedKey(component.props.get('key'));
    }
    return untyped index.toString(36);
  }

  public static inline var SEPARATOR = '.';
  public static inline var SUBSEPARATOR = ':';

  public static function traverseAllChildren(children:Array<rx.core.Component>, callback: Dynamic, traverseContext: Map<String, rx.core.Component>) {
    for (i in 0...children.length) {
      var child = children[i];
      var storageName = SEPARATOR + getComponentKey(child, i);
      callback(traverseContext, child, storageName, '');
    }
  }

}