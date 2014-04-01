package rx.core;

class Context implements Dynamic {
  public static var current: Context = null;

  public static function withContext(newContext: Dynamic, scopedCallback: Dynamic) {
    // TODO: Merge
    return newContext;
  }
}