package ;

import rx.browser.ui.DOM;

class MyComponent extends rx.core.CompositeComponent<Dynamic> {
  public function new() super();

  public override function render():rx.core.Component {

    return DOM.el('div', [
      DOM.el('div', [DOM.text('Hello')]),
      DOM.el('div', [DOM.text('World')]),
    ]);

  }
}

class App {
  public static function main():Void {
    
    var d = js.Browser.document;
    d.addEventListener('DOMContentLoaded', function (event: js.html.Event) {
      var container = d.getElementById('app');
      rx.browser.ui.Mount.renderComponent(new MyComponent(), container);
    });
  }
}