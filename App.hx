package ;

import rx.browser.ui.DOM;
import rx.core.CompositeComponent;

class First extends CompositeComponent<Dynamic> {
  public override function render() {
    return DOM.el('div', [DOM.text('One')]);
  }
}

class Second extends CompositeComponent<Dynamic> {
  public override function render() {
    return DOM.el('div', [DOM.text('Two')]);
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
    }, 300);
  }

  public override function render() {

    return DOM.el('div', [ this.state ?
      new First() :
      new Second()
    ], {
      'data-component': 'Hello'
    });
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
