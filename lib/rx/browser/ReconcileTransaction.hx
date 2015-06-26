package rx.browser;

import rx.utils.Transaction;
import rx.utils.PooledClass;

import rx.core.MountReady;
import rx.browser.PutListenerQueue;

class ReconcileTransaction extends Transaction {

  public static var pool = new PooledClass<ReconcileTransaction>();

  public inline override function getTransactionWrappers():Array<rx.utils.Transaction.Wrapper> {

    var selectionRestoration = {
      initialize: function () {},
      close: function () {}
    };

    var eventSupression = {
      initialize: function () {},
      close: function () {}
    };

    var onDomReadyQueueing = {
      initialize: function () {
        mountReady.reset();
      },
      close: function () {
        mountReady.notifyAll();
      }
    };

    var putListenerQueueing = {
      initialize: function () {
        putListenerQueue.reset();
      },
      close: function () {
        putListenerQueue.putListeners();
      }
    };

    return [selectionRestoration, eventSupression, onDomReadyQueueing, putListenerQueueing];

  }

  public var renderToStaticMarkup: Bool;
  public var mountReady: MountReady;
  var putListenerQueue: PutListenerQueue;

  public function new(_) {
    reinitializeTransaction();
    renderToStaticMarkup = false;
    mountReady = MountReady.pool.getPooled();
    putListenerQueue = PutListenerQueue.pool.getPooled();
  }

  public inline function getMountReady():MountReady {
    return mountReady;
  }

  public inline function getPutListenerQueue():PutListenerQueue {
    return putListenerQueue;
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
