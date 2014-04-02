package rx.utils;

class Utils {
  
  public static var SEPARATOR = '.';
  public static var SUBSEPARATOR = ':';
  public static function traverseAllChildrenImpl(children: Array<rx.core.Component>, nameSoFar:String, indexSoFar:Int, callback:Dynamic, traverseContext:Dynamic):Int {
    var subtreeCount = 0;
    if (children != null && children.length > 0) {
      for (i in 0...children.length) {
        var child = children[i];
        var nextName = nameSoFar;
        if (nameSoFar == '') {
          nextName += SUBSEPARATOR;
        } else {
          nextName += SEPARATOR;
        }
        nextName += getComponentKey(child, i);
        var nextIndex = indexSoFar + subtreeCount;

        if (child.children != null && child.children.length > 0) {
          subtreeCount += traverseAllChildrenImpl(
            child.children,
            nextName,
            nextIndex,
            callback,
            traverseContext
          );
        } else {
          var storageName = nameSoFar + SEPARATOR + getComponentKey(child, 0);
          callback(traverseContext, child, storageName, indexSoFar);
          // subtreeCount = 1;
        }
      }
    }
    return subtreeCount;
  }

  static var userProvidedKeyEscaperLookup: Map<String, String> = [
    '='=> '=0',
    '.'=> '=1',
    ':'=> '=2'
  ];

  static var userProvidedKeyEscapeRegex:EReg = ~/[=.:]/g;

  public static function userProvidedKeyEscaper(match) {
    return userProvidedKeyEscaperLookup.get(match);
  }

  public static function escapeUserProvidedKey(text:String) {
    return userProvidedKeyEscapeRegex.replace(text, '=0');
  }

  public static function wrapUserProvidedKey(key:String) {
    return "$" + escapeUserProvidedKey(key);
  }

  public static function getComponentKey(component:rx.core.Component, index:Int) {
    if (component != null && component.props != null && component.props.get('key') != null) {
      // Explicit key
      return wrapUserProvidedKey(component.props.get('key'));
    }
    // Implicit key determined by the index in the set
    return untyped index.toString(36);
  }

  public static function traverseAllChildren(children:Array<rx.core.Component>, callback: Dynamic, traverseContext: Map<String, rx.core.Component>) {
    if (children != null) {
      traverseAllChildrenImpl(children, '', 0, callback, traverseContext);
    }
  }

  public static function flattenSingleChildIntoContext(traverseContext, child:rx.core.Component, name:String) {
    // We found a component instance.
    var result = traverseContext;
    if (child != null) {
      result.set(name, child);
    }
  }

  public static function flattenChildren(children: Array<rx.core.Component>):Map<String, rx.core.Component> {
    if (children == null) return null;
    var result = new Map<String, rx.core.Component>();
    traverseAllChildren(children, flattenSingleChildIntoContext, result);
    return result;
  }
}