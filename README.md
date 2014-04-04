#React.hx

##About

React.hx - is a [React](https://github.com/facebook/react/) javascript framework ported to Haxe.

**Work in progres**

##Sample usage

```haxe
package ;

import rx.browser.ui.DOM;
import rx.core.CompositeComponent;

class SwitchComponent extends CompositeComponent<Bool> {

  public override function getInitialState() {
    return true;
  }

  var interval: Int;

  public override function componentDidMount() {
    js.Browser.window.setInterval(function() {
      this.setState(!this.state);
    }, 500);
  }

  public override function render() {

    return DOM.el('div', [ this.state ?
      DOM.text('One') :
      DOM.text('Two')
    ]);
  }

}

class App {
  public static function main():Void {

    var d = js.Browser.document;
    d.addEventListener('DOMContentLoaded', function (event: js.html.Event) {

      var container = d.getElementById('app');
      rx.browser.ui.Mount.renderComponent(new SwitchComponent(), container);

    });
  }
}
```

## Not ready

- Events
- Tests
- Optimizations
