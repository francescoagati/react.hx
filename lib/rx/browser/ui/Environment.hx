package rx.browser.ui;

class Environment {
  public static function mountImageIntoNode(markup:String, container:js.html.Element, shouldReuseMarkup: Bool) {
    //TODO: reuse markup
    container.innerHTML = markup;
  }

  public static function unmountIdFromEnvironment(rootNodeId: String) {
    rx.browser.ui.Mount.purgeId(rootNodeId);
  }
}