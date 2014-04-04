= React.hx

== Facebook's React.js - Haxe port (WIP)

Sample usage

```haxe

import rx.browser.ui.DOM;
class SomeComponent extends rx.core.CompositeComponent<Dynamic> {
  public override function render() {
    return DOM.el('div', [
      DOM.text('Hello world')
    ]);
  }
}

class App {

  public static function main():Void {

    var d = js.Browser.document;
    d.addEventListener('DOMContentLoaded', function (event: js.html.Event) {

      var container = d.getElementById('app');
      rx.browser.ui.Mount.renderComponent(new SomeComponent(), container);

    });
  }
}

```
