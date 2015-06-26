package rx.core;

import rx.core.Descriptor;
import rx.core.Props;
import rx.browser.ReconcileTransaction;
import rx.browser.ui.Environment;
import rx.core.Owner;
using rx.core.ComponentTools;

enum Lifecycle {
  Mounted;
  Unmounted;
}

class Component extends Owner {

  public  static function shouldUpdate(prevComponent: Component, nextComponent:Component):Bool {

    if (prevComponent != null &&
        nextComponent != null &&
        prevComponent.type == nextComponent.type &&
        prevComponent.props.get('key') == nextComponent.props.get('key')) {

      if (prevComponent.owner == nextComponent.owner) {
        return true;
      }

    }

    return false;
  }

  public var props: Props;
  public var context: rx.core.Context;
  public var owner: Owner;
  public var descriptor:Descriptor;
  public var type: String;

  var pendingDescriptor: Descriptor;
  var pendingProps: Props;
  var pendingOwner: Owner;
  public var lifecycleState: Lifecycle;

  public var pendingCallbacks: Array<Dynamic>;
  public var mountDepth: Int;
  public var mountIndex: Int;
  public var rootNodeId: String;

  public  function isMounted():Bool return lifecycleState == Lifecycle.Mounted;

  public inline function isOwnedBy(owner:Owner):Bool {
    return owner == this.owner;
  }

  public inline function setProps(partialProps: Props, callback: Dynamic) {
    var descr = pendingDescriptor;
    if (descr == null) descr = descriptor;
    replaceProps(
      rx.core.Tools.merge(descr.props, partialProps),
      callback
    );
  }

  public inline function replaceProps(props:Props, callback: Dynamic) {
    if (!isMounted()) throw 'Can only update a mounted component';
    if (mountDepth != null) throw 'You called `setProps` or `replaceProps` on a component with a parent.';

    var descr = pendingDescriptor;
    if (descr == null) descr = this.descriptor;

    this.pendingDescriptor = Descriptor.cloneAndReplaceProps(descr, props);
    rx.core.Updates.enqueueUpdate(this, callback);
  }

  public  inline function new(descriptor: Descriptor) {
    super();
    this.props = descriptor.props;
    this.descriptor = descriptor;
    this.type = Type.getClassName(Type.getClass(this));

    this.context = rx.core.Context.current;
    this.owner = Owner.current;

    this.lifecycleState = Lifecycle.Unmounted;
    this.pendingCallbacks = null;

    this.pendingDescriptor = null;

  }

  public  function mountComponent(rootId: String, transaction: ReconcileTransaction, mountDepth: Int):String {
    return this.ext_mountComponent(rootId, transaction, mountDepth);
    // var props = this.props;
    // if (props != null && props.get('ref') != null) {
    //   var owner = this.owner;
    //   Owner.addComponentAsRefTo(this, props.get('ref'), owner);
    // }
    // this.rootNodeId = rootId;
    // this.lifecycleState = Lifecycle.Mounted;
    // this.mountDepth = mountDepth;
    // return null;
  }

  public inline function _mountComponentIntoNode(rootId:String, container:js.html.Element, transaction: ReconcileTransaction, shouldReuseMarkup:Bool) {
    var markup = mountComponent(rootId, transaction, 0);
    Environment.mountImageIntoNode(markup, container, shouldReuseMarkup);
  }

  public  inline function mountComponentIntoNode(rootId, container, shouldReuseMarkup) {
    var transaction = ReconcileTransaction.pool.getPooled();
    transaction.perform(
      _mountComponentIntoNode,
      this, [rootId, container, transaction, shouldReuseMarkup]
    );
    ReconcileTransaction.pool.release(transaction);
  }

  public  function receiveComponent(nextComponent:Component, transaction:ReconcileTransaction) {
    pendingOwner = nextComponent.owner;
    pendingProps = nextComponent.props;
    _performUpdateIfNecessary(transaction);
  }

  public function _performUpdateIfNecessary(transaction) {
    if (this.pendingProps == null) {
      return;
    }
    var prevProps = this.props;
    var prevOwner = this.owner;

    this.props = this.pendingProps;
    this.owner = this.pendingOwner;

    this.pendingProps = null;
    this.updateComponent(transaction, prevProps, prevOwner);
  }

  public function performUpdateIfNecessary() {
    var transaction = ReconcileTransaction.pool.getPooled();
    transaction.perform(this._performUpdateIfNecessary, this, [transaction]);
    ReconcileTransaction.pool.release(transaction);
  }

  public function updateComponent(
    transaction:ReconcileTransaction,
    prevProps:Props,
    prevOwner: Owner,
    ?prevState: Dynamic,
    ?prevContext: Dynamic) {

    var props = this.props;
    // If either the owner or a `ref` has changed, make sure the newest owner
    // has stored a reference to `this`, and the previous owner (if different)
    // has forgotten the reference to `this`.
    if (this.owner != prevOwner || props.get('ref') != prevProps.get('ref')) {
      if (prevProps != null && prevProps.get('ref') != null) {
        Owner.removeComponentAsRefFrom(this, prevProps.get('ref'), prevOwner);
      }
      // Correct, even if the owner is the same, and only the ref has changed.
      if (props != null && props.get('ref') != null) {
        Owner.addComponentAsRefTo(this, props.get('ref'), this.owner);
      }
    }

  }

  public inline function unmountComponent() {
    if (!isMounted()) throw 'Can only unmount a mounted component.';
    var props = this.props;
    if (props.get('ref') != null) {
      Owner.removeComponentAsRefFrom(this, props.get('ref'), this.owner);
    }
    Environment.unmountIdFromEnvironment(rootNodeId);
    rootNodeId = null;
    lifecycleState = Lifecycle.Unmounted;
  }
}
