package rx.core;

class Tools {
  public static function mergeInto(one: Props, two: Props) {

    for (key in two.keys()) {
      one.set(key, two.get(key));
    }

  }

  public static function merge(one: Props, two: Props) {
    var result = {};
    mergeInto(result, one);
    mergeInto(result, two);
    return result;
  }
}