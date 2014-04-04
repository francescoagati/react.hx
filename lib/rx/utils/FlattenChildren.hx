package rx.utils;


import rx.core.Component;
import rx.core.Props;

class FlattenChildren {
  public static function flattenSingleChildIntoContext(traverseContext: Props, child:Component, name:String) {
    // We found a component instance.
    var result = traverseContext;
    if (result.exists(name)) throw 'flattenChildren(...): Incountered two children with the same key, $name';
    if (child != null) {
      result.set(name, child);
    }
  }

  public static function flattenChildren(children: Array<Component>):Props {
    if (children == null) return null;
    var result = {}
    TraverseChildren.traverseAllChildren(children, flattenSingleChildIntoContext, result);
    return result;
  }
}