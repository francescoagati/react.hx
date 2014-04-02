package rx.browser.ui;

class DOM {
  public static var tagsMap: Map<String, Bool> = [
    'a' => false,
    'b' => false,
    'button' => false,
    'form' => false,
    'div' => false,
    'span' => false
  ];

  public static function el(tagName: String, ?children: Array<rx.core.Component> = null, ?props: rx.core.Descriptor.Props = null) {
    var descriptor = new rx.core.Descriptor(children, props);
    return new rx.browser.ui.dom.Component(tagName, tagsMap.get(tagName), descriptor);
  }

  public static function text(text: String):rx.core.Component {
    var descriptor = new rx.core.Descriptor();
    return new rx.browser.ui.dom.components.Text(text, descriptor); 
  }
}