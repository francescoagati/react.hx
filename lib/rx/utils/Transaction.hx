package rx.utils;

typedef Wrapper = {
  ?initialize: Void->Void,
  ?close: Void->Void
}

typedef TimingMetrics = {
  ?methodInvocationTime: Int,
  ?wrapperInitTimes: Array<Int>,
  ?wrapperCloseTimes: Array<Int>
};

class Transaction {
  public var transactionWrappers: Array<Wrapper>;
  public var wrappersInitData: Array<Dynamic>;
  public var timingMetrics:TimingMetrics;
  var _isInTransaction: Bool;
  public function getTransactionWrappers():Array<Wrapper> {
    return [];
  }

  public function reinitializeTransaction():Void {
    transactionWrappers = getTransactionWrappers();
    wrappersInitData = [];
    if (timingMetrics == null) {
      timingMetrics = {};
    }
    timingMetrics.methodInvocationTime = 0;
    timingMetrics.wrapperInitTimes = [];
    timingMetrics.wrapperCloseTimes = [];
    _isInTransaction = false;

  }

  public function perform(method:Dynamic, scope:Dynamic, args: Array<Dynamic>):Dynamic {
    var ret = null;
    _isInTransaction = true;
    try {
      initializeAll(0);
      ret = Reflect.callMethod(scope, method, args);
    } catch(e: Dynamic) {};

    closeAll(0);
    _isInTransaction = false;
    return ret;
  }

  public function isInTransaction():Bool {
    return _isInTransaction;
  }

  public function initializeAll(startIndex: Int):Void {
    var wrappers = getTransactionWrappers();
    for (i in startIndex...wrappers.length) {
      var wrapper = wrappers[i];
      wrapper.initialize();
    }
  }

  public function closeAll(startIndex: Int):Void {
    var wrappers = getTransactionWrappers();
    for (i in startIndex...wrappers.length) {
      var wrapper:Wrapper = wrappers[i];
      wrapper.close();
    }
  }
}