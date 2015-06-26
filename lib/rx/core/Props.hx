package rx.core;


class Helper {
  public static inline function deleteField(o,field) {
    untyped __js__('delete({0}[{1}]);',o,field);
    return true;
  }

  public static inline function fields(obj) {
    return untyped __js__('Object.keys({0})',obj);
  }

}

abstract Props({}) from {} {
  inline function new(a:Dynamic)
    this = a;
  public inline function get(name: String):Dynamic return untyped this[name];
    public inline function keys():Array<String> {
      #if js
        return Props.Helper.fields(this);
      #else
        return Reflect.fields(this);
      #end
    }
    public inline function set(name: String, value: Dynamic):Void untyped this[name] = value;
    public inline function exists(name: String):Bool return untyped this[name] != undefined;
    public inline function remove(name: String) {
        #if js
          Props.Helper.deleteField(this,name);
        #else
          untyped Reflect.deleteField(this, name);
        #end
    }
}
