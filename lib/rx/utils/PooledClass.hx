package rx.utils;

@:generic class PooledClass<T:({function new(arg1: Dynamic):Void;})> {
  var poolSize: Int = 10;
  var instance: T;
  var pool: Array<T>;
  public function new(?poolSize: Int) {
    if (poolSize != null) this.poolSize = poolSize;
    pool = new Array<T>();
  }

  public function getPooled(?arg1:Dynamic):T {
    if (pool.length > 0) {
      return pool.pop();
    } else {
      return new T(arg1);
    }
  }

  public function release(instance:T) {
    if (Reflect.hasField(instance, 'reset')) {
      Reflect.callMethod(instance, Reflect.getProperty(instance, 'reset'), []);
    }
    pool.push(instance);
  }
}