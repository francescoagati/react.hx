package rx.core;

class BatchingTransaction extends rx.utils.Transaction {

  public function new() {
    this.reinitializeTransaction();
  };

  public override function getTransactionWrappers():Array<rx.utils.Transaction.Wrapper> {
    var resetBatchUpdatesWrapper = {
      initialize: function () {},
      close: function () {
        BatchingStrategy.isBatchingUpdates = false;
      }
    };
    var flushBatchedUpdatesWrapper = {
      initialize: function () {},
      close: function () {
        rx.core.Updates.flushBatchedUpdates();
      }
    };
    return [resetBatchUpdatesWrapper, flushBatchedUpdatesWrapper];
  }

}

class BatchingStrategy {
  public static var isBatchingUpdates: Bool = false;
  public static var transaction: BatchingTransaction = new BatchingTransaction();
  public static function batchUpdates(callback: Dynamic, param: Dynamic) {

    var alreadyBathingUpdates = BatchingStrategy.isBatchingUpdates;

    BatchingStrategy.isBatchingUpdates = true;

    if (alreadyBathingUpdates) {
      callback(param);
    } else {
      transaction.perform(callback, null, [param]);
    }

  }
}