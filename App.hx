package ;

import rx.browser.ui.DOM;

class App {
  public static function main():Void {
    
    var component = DOM.el('div', [
      DOM.el('div', [DOM.text('Hello')]),
      DOM.el('div', [DOM.text('World')])
    ]);

    var d = js.Browser.document;
    d.addEventListener('DOMContentLoaded', function (event: js.html.Event) {
      var container = d.getElementById('app');
      rx.browser.ui.Mount.renderComponent(component, container);
    });
  }
}