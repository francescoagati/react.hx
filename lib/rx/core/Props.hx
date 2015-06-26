package rx.core;

abstract Props({}) from {} {
  inline function new(a:Dynamic)
    this = a;
  public inline function get(name: String):Dynamic return untyped this[name];
    public inline function keys():Array<String> return Reflect.fields(this);
    public inline function set(name: String, value: Dynamic):Void untyped this[name] = value;
    public inline function exists(name: String):Bool return untyped this[name] != undefined;
    public inline function remove(name: String) untyped Reflect.deleteField(this, name);
}
