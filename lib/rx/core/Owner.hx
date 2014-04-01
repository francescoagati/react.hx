package rx.core;

class Owner {

  public static var current: Owner = null;

  public static function isValidOwner(object) {
    return true;
  }

  public static function addComponentAsRefTo(component: rx.core.Component, ref: String, owner: Owner) {
    owner.attachRef(ref, component);
  }

  public static function removeComponentAsRefFrom(component: rx.core.Component, ref: String, owner: Owner) {
    if (owner.refs.get(ref) == component) {
      owner.detachRef(ref);
    }
  }

  var refs: Map<String, rx.core.Component>;
  public function new() {
    refs = new Map<String, rx.core.Component>();
  }

  public function attachRef(ref:String, component: rx.core.Component):Void {
    if (!component.isOwnedBy(this)) throw 'Only a component\'s owner can store a ref to it.';
    refs.set(ref, component);
  }

  public function detachRef(ref:String):Void {
    refs.remove(ref);
  }

}