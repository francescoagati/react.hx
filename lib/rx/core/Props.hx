package rx.core;

abstract Props({}) from {} {
  inline function new(a:Dynamic)
    this = a;
  inline function get(name: String):Dynamic
    return untyped this[name];
  inline function keys():Array<String>
    return Reflect.fields(this);
  inline function set(name: String, value: Dynamic):Void
    untyped this[name] = value;
  inline function exists(name: String):Bool
    return untyped this[name] != undefined;
  inline function remove(name: String)
    untyped Reflect.deleteField(this, name);
}