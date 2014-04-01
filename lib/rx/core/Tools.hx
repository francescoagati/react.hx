package rx.core;

class Tools {
  public static function mergeInto(one: Map<String, Dynamic>, two: Map<String, Dynamic>) {

    for (key in two.keys()) {
      one.set(key, two.get(key));
    }
  }

  public static function merge(one: Map<String, Dynamic>, two: Map<String, Dynamic>) {
    var result = new Map<String, Dynamic>();
    mergeInto(result, one);
    mergeInto(result, two);
    return result;
  }
}