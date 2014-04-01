package rx.utils;

typedef Wrapper = {
  initialize: Void->Void,
  close: Void->Void
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
  public function getTransactionWrappers() {
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
    return Reflect.callMethod(scope, method, args);
  }

  public function isInTransaction():Bool {
    return _isInTransaction;
  }

  public function initializeAll(startIndex: Int):Void {

  }

  public function closeAll(startIndex: Int):Void {

  }
}