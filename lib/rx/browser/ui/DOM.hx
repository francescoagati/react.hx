package rx.browser.ui;

import rx.core.Component;
import rx.core.Descriptor;
import rx.core.Props;

import rx.browser.ui.dom.Component in DomComponent;
import rx.browser.ui.dom.components.Text in TextComponent;

class DOM {

  static var emptyDescriptor = new rx.core.Descriptor(null, null);
  public static var tagsMap: rx.core.Props = {
    a: false,
    b: false,
    button: false,
    form: false,
    div: false,
    span: false
  };

  public static function el(tagName: String, ?children: Array<Component> = null, ?props: Props = null) {
    var descriptor = new Descriptor(children, props);
    return new DomComponent(tagName, tagsMap.get(tagName), descriptor);
  }

  public static function text(text: String):Component {
    return new TextComponent(text, emptyDescriptor);
  }
}