package ;

import rx.browser.ui.DOM;

class RootState {
  public var splitter: String = ' ';
  public function new(splitter) { this.splitter = splitter; };
}

class MyComponent extends rx.core.CompositeComponent<RootState> {
 
  public override function getInitialState() {
    return new RootState(' ');
  }

  public override function componentDidMount() {

    js.Browser.window.setTimeout(function () {
      this.setState(new RootState('-'));
    }, 1000);
    
  }

  public override function componentWillUpdate(props, state, context) {
    trace('Will update', state);
  }

  public override function componentDidUpdate(props, state, context) {
    trace('Did update', state);
  }

  public override function render():rx.core.Component {
    return DOM.el('div', [for (i in 0...3) 
      DOM.el('div', [
        DOM.text('Hello world'),
        DOM.text(this.state.splitter),
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
      js.Browser.window.setTimeout(function () {
        var end = Date.now().getTime() - start;
        trace('Execution time: $end');
      }, 0);
      
    });
  }
}