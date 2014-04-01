package ;

import rx.browser.ui.DOM;

class App {
  public static function main():Void {
    
    var component = DOM.el('div', [
      DOM.el('span', []),
      DOM.el('span', [])
    ]);

    var code = component.mountComponent('test' , rx.browser.ReconcileTransaction.pool.getPooled() , 0 );
    trace(code);
  }
}