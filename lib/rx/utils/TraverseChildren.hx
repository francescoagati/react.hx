package rx.utils;

class TraverseChildren {

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

  public static var SEPARATOR = '.';
  public static var SUBSEPARATOR = ':';
  public static function traverseAllChildrenImpl(children: Array<rx.core.Component>, nameSoFar:String, indexSoFar:Int, callback:Dynamic, traverseContext:Dynamic):Int {
    var subtreeCount = 0;
    var isOnlyChild = (nameSoFar == '');
    if (children != null && children.length > 0) {

      for (i in 0...children.length) {
        var child = children[i];
        var storageName = isOnlyChild ? SEPARATOR + getComponentKey(child, i) : nameSoFar;
        callback(traverseContext, child, storageName, indexSoFar);
        // var nextName = nameSoFar + (isOnlyChild ? SUBSEPARATOR : SEPARATOR) + getComponentKey(child, i);
        // var nextIndex = indexSoFar + subtreeCount;
        // subtreeCount += traverseAllChildrenImpl(child.children, nextName, nextIndex, callback, traverseContext);
        subtreeCount += 1;
      }

    }
    return subtreeCount;
  }

  public static function traverseAllChildren(children:Array<rx.core.Component>, callback: Dynamic, traverseContext: Map<String, rx.core.Component>) {
    if (children != null) {
      traverseAllChildrenImpl(children, '', 0, callback, traverseContext);
    }
  }

}