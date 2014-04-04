package ;

import rx.browser.ui.DOM;
import rx.core.Component;
import rx.core.CompositeComponent;

class InnerComponent extends CompositeComponent<Dynamic> {
  public override function render() {
    return DOM.text('Hello');
  }
}

class ListComponent extends CompositeComponent<Int> {

  public override function getInitialState() {
    return 10;
  }

  var interval: Int;
  var diff: Int = -1;

  public override function componentDidMount() {
    interval = js.Browser.window.setInterval(function() {
      this.setState(this.state - diff);
      if (this.state == 0 || this.state == 40) diff = -diff;
    }, 5);
  }

  public override function render() {
    return DOM.el('ul', [for(i in 0...this.state) DOM.el('li', [new InnerComponent()])]);
  }

}

class App {
  public static function main():Void {

    var d = js.Browser.document;
    d.addEventListener('DOMContentLoaded', function (event: js.html.Event) {

      var container = d.getElementById('app');
      var start = Date.now().getTime();
      rx.browser.ui.Mount.renderComponent(new ListComponent(), container);
      js.Browser.window.setTimeout(function () {
        var end = Date.now().getTime() - start;
      }, 0);

    });
  }
}
