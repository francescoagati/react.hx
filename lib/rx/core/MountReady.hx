package rx.core;

class MountReady {
  public static var pool = new rx.utils.PooledClass<MountReady>();

  var queue: Array<Dynamic> = new Array<Dynamic>();
  public function new(initalCollection: Dynamic) {
    if (initalCollection != null)
      queue = initalCollection;
  }

  public function enqueue(component: rx.core.Component, callback:Dynamic, ?args: Array<Dynamic> = null) {
    queue.push({component: component, callback: callback, args: args});
  }

  public function notifyAll() {
    var q = queue;
    if (q != null) {
      for (item in q) {
        var component = item.component;
        var callback = item.callback;
        var args = item.args;
        Reflect.callMethod(component, callback, args);
      }
      queue.splice(0, queue.length);
    }
  }

  public function reset() {
    queue.splice(0, queue.length);
  }

  public function destruct() {
    reset();
  }
}