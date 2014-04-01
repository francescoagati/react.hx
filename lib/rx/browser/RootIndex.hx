package rx.browser.ui;

class RootIndex {
  private static var _rootIndex: Int = 0;
  public static function rootIndex():Int {
    return _rootIndex++;
  }
}