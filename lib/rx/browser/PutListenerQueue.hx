package rx.browser;

import rx.utils.PooledClass;

typedef Listener = {
  rootNodeId: String,
  propKey: String,
  propValue: Dynamic
};

class PutListenerQueue {

  public static var pool = new PooledClass<PutListenerQueue>();

  var listenersToPut: Array<Listener>;
  public function new(_) {
    listenersToPut = new Array<Listener>();
  }

  public function enqueuePutListener(rootNodeId: String, propKey: String, propValue: Dynamic) {
    listenersToPut.push({
      rootNodeId: rootNodeId,
      propKey: propKey,
      propValue: propValue
    });
  }

  public function putListeners():Void {
    for (listener in listenersToPut) {
      EventEmitter.putListener(
        listener.rootNodeId,
        listener.propKey,
        listener.propValue
      );
    }
  }

  public function reset() {
    listenersToPut.splice(0, listenersToPut.length);
  }

  public function destructor() {
    reset();
  }

}