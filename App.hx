package ;

import rx.browser.ui.DOM;
import rx.core.Component;
import rx.core.CompositeComponent;

class FirstComponent extends CompositeComponent<Dynamic> {
  public override function render() {
    return DOM.text('Hello');
  }
}

class SecondComponent extends CompositeComponent<Dynamic> {
  public override function render() {
    return DOM.text('World');
  }
}

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

  public override function componentWillUpdate(props, owner, context) {

  }

  public override function render() {

    return DOM.el('div', [ this.state ? new FirstComponent() : new SecondComponent() ]);
  }

}

class App {
  public static function main():Void {

    var d = js.Browser.document;
    d.addEventListener('DOMContentLoaded', function (event: js.html.Event) {

      var container = d.getElementById('app');
      var start = Date.now().getTime();
      rx.browser.ui.Mount.renderComponent(new SwitchComponent(), container);
      js.Browser.window.setTimeout(function () {
        var end = Date.now().getTime() - start;
      }, 0);

    });
  }
}
