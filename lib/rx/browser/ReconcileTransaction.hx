package rx.browser;

class ReconcileTransaction extends rx.utils.Transaction {

  public static var pool = new rx.utils.PooledClass<ReconcileTransaction>();

  public override function getTransactionWrappers():Array<rx.utils.Transaction.Wrapper> {

    var selectionRestoration = {
      initialize: function () {},
      close: function () {}
    };

    var eventSupression = {
      initialize: function () {},
      close: function () {}
    };

    var onDomReadyQueueing = {
      initialize: function () {},
      close: function () {}
    };

    var putListenerQueueing = {
      initialize: function () {},
      close: function () {}
    };

    return [selectionRestoration, eventSupression, onDomReadyQueueing, putListenerQueueing];

  }

  public var renderToStaticMarkup: Bool;
  public var mountReady: rx.core.MountReady;
  var putListenerQueue: rx.browser.PutListenerQueue;

  public function new(_) {
    reinitializeTransaction();
    renderToStaticMarkup = false;
    mountReady = rx.core.MountReady.pool.getPooled();
    putListenerQueue = rx.browser.PutListenerQueue.pool.getPooled();
  }

  public function getMountReady():rx.core.MountReady {
    return mountReady;
  }


  /*
  public static var pool: Pooler<ReconcileTransaction> = new Pooler<ReconcileTransaction>();
  public static function release(transaction: ReconcileTransaction):Void {
    pool.release(transaction);
  }

  var mountReady: MountReady;
  var putListenerQueue: PutListenerQueue;

  public function new(_) {
    super(null);
    mountReady = MountReady.pool.getPooled();
    putListenerQueue = PutListenerQueue.pool.getPooled();
  }

  public function getMountReady() {
    return mountReady;
  }

  public function reset() {
    mountReady.release();
    mountReady = null;
    putListenerQueue.release();
    putListenerQueue = null;
  }
  */
}