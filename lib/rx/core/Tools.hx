package rx.core;

class Tools {
  public inline static function mergeInto(one: Props, two: Props) {

    for (key in two.keys()) {
      one.set(key, two.get(key));
    }

  }

  public inline static function merge(one: Props, two: Props) {
    var result = {};
    mergeInto(result, one);
    mergeInto(result, two);
    return result;
  }
}
