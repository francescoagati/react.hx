package rx.core;

class MountReady {
  public static var pool = new rx.utils.PooledClass<MountReady>();

  var queue: Array<Dynamic> = new Array<Dynamic>();
  public function new(initalCollection: Dynamic) {
    if (initalCollection != null)
      queue = initalCollection;
  }

  public function enqueue(component: rx.core.Component, callback:Dynamic) {
    queue.push({component: component, callback: callback});
  }

  public function notifyAll() {
    var q = queue;
    if (q != null) {
      for (item in q) {
        var component = item.component;
        var callback = item.callback;
        Reflect.callMethod(component, callback, []);
      }
      queue = new Array<Dynamic>();
    }
  }

  public function reset() {
    queue = new Array<Dynamic>();
  }

  public function destruct() {
    reset();
  }
}