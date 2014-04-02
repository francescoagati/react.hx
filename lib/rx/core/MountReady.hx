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
}