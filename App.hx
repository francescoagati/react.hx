package ;

class App {
  public static function main():Void {
    
    var div1Descriptor = new rx.core.Descriptor(null, null);

    var descriptor = new rx.core.Descriptor([
      new rx.browser.ui.DOMComponent('div', false, div1Descriptor),
      new rx.browser.ui.DOMComponent('div', false, div1Descriptor)
    ], null);
    var cmp = new rx.browser.ui.DOMComponent('div', false, descriptor);
    var code = cmp.mountComponent('test' , rx.browser.ReconcileTransaction.pool.getPooled() , 0 );
    trace(code);
  }
}