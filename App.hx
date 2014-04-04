package ;

import rx.browser.ui.DOM;

class RootState {
  public var splitter: String = ' ';
  public function new(splitter) { this.splitter = splitter; };
}

class MyComponent extends rx.core.CompositeComponent<RootState> {

  var c = 0;
  public override function getInitialState() {
    return new RootState(Std.string(c));
  }

  var time = Date.now().getTime();
  var interval: Int;
  public override function componentDidMount() {
    interval = js.Browser.window.setInterval(function() {
      this.setState(new RootState(Std.string(c++)));
    }, 16);
  }

  public override function componentWillUpdate(props, state, context) {
    time = Date.now().getTime();
  }

  var fail: Int = 0;
  public override function componentDidUpdate(props, state, context) {
    var diff = Date.now().getTime() - time;
    if (diff > 16) {
      fail++;
      trace('Whoops: $c - $diff');
      if (fail > 5)
        js.Browser.window.clearInterval(interval);
    }
  }

  public override function render():rx.core.Component {
    return DOM.el('div', [for(i in 0...c) DOM.el('div', [
        DOM.text('Hello '),
        DOM.text(this.state.splitter),
        DOM.text(' World')
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
      js.Browser.window.setTimeout(function () {
        var end = Date.now().getTime() - start;
        trace('Execution time: $end');
      }, 0);

    });
  }
}
