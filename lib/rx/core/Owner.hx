package rx.core;

import rx.core.Component;

class Owner {

  public static var current: Owner = null;

  public static function isValidOwner(object) {
    return true;
  }

  public static function addComponentAsRefTo(component: Component, ref: String, owner: Owner) {
    owner.attachRef(ref, component);
  }

  public static function removeComponentAsRefFrom(component: Component, ref: String, owner: Owner) {
    if (owner.refs.get(ref) == component) {
      owner.detachRef(ref);
    }
  }

  var refs: rx.core.Props;
  public function new() {
    refs = {};
  }

  public function attachRef(ref:String, component: Component):Void {
    if (!component.isOwnedBy(this)) throw 'Only a component\'s owner can store a ref to it.';
    refs.set(ref, component);
  }

  public function detachRef(ref:String):Void {
    refs.remove(ref);
  }

}