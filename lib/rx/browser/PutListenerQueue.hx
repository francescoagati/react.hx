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

  public inline function enqueuePutListener(rootNodeId: String, propKey: String, propValue: Dynamic) {
    listenersToPut.push({
      rootNodeId: rootNodeId,
      propKey: propKey,
      propValue: propValue
    });
  }

  public inline function putListeners():Void {
    for (listener in listenersToPut) {
      EventEmitter.putListener(
        listener.rootNodeId,
        listener.propKey,
        listener.propValue
      );
    }
  }

  public inline function reset() {
    listenersToPut.splice(0, listenersToPut.length);
  }

  public inline function destructor() {
    reset();
  }

}
