package rx.utils;

class FlattenChildren {
  public static function flattenSingleChildIntoContext(traverseContext: Map<String, rx.core.Component>, child:rx.core.Component, name:String) {
    // We found a component instance.
    var result = traverseContext;
    if (result.exists(name)) throw 'flattenChildren(...): Incountered two children with the same key, $name';
    if (child != null) {
      result.set(name, child);
    }
  }

  public static function flattenChildren(children: Array<rx.core.Component>):Map<String, rx.core.Component> {
    if (children == null) return null;
    var result = new Map<String, rx.core.Component>();
    TraverseChildren.traverseAllChildren(children, flattenSingleChildIntoContext, result);
    return result;
  }
}