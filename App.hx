package ;

import rx.browser.ui.DOM;

class MyComponent extends rx.core.CompositeComponent<Dynamic> {
 
  public override function render():rx.core.Component {
    return DOM.el('div', [for (i in 0...2000) 
      DOM.el('div', [
        DOM.text('Hello'),
        DOM.text(' '),
        DOM.text('World'),
        DOM.text(' '),
        DOM.text(Std.string(i))
      ])
    ]);
  }
}

class App {
  public static function main():Void {
    
    var d = js.Browser.document;
    d.addEventListener('DOMContentLoaded', function (event: js.html.Event) {

      var container = d.getElementById('app');
      var start = Date.now().getTime();
      rx.browser.ui.Mount.renderComponent(new MyComponent(), container);
      var end = Date.now().getTime() - start;
      trace('Execution time: $end');
    });
  }
}