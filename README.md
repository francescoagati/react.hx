#React.hx

##About

React.hx - is a [React](https://github.com/facebook/react/) javascript framework ported to Haxe.

**Work in progres**

##Sample usage

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

## Not ready

- Events
- Tests
- Optimizations
