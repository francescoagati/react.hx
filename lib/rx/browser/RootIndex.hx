package rx.browser;

class RootIndex {
  private static var _rootIndex: Int = 0;
  public inline static function createReactRootIndex():Int {
    return _rootIndex++;
  }
}
