package rx.core;

enum Lifecycle {
  Mounted;
  Unmounted;
}

class Component {
  
  public var props: rx.core.Descriptor.Props;
  public var children: Array<rx.core.Component>;
  var context: rx.core.Context;
  var owner: rx.core.Owner;
  public var descriptor:Descriptor;
  var pendingDescriptor:Descriptor;

  var lifecycleState: Lifecycle;

  public var pendingCallbacks: Array<Dynamic>;
  public var mountDepth: Int;
  public var mountIndex: Int;
  public var rootNodeId: String;

  public function isMounted():Bool return lifecycleState == Lifecycle.Mounted;

  public function isOwnedBy(owner:rx.core.Owner):Bool {
    return owner == this.owner;
  }

  public function setProps(partialProps: rx.core.Descriptor.Props, callback: Dynamic) {
    var descr = pendingDescriptor;
    if (descr == null) descr = descriptor;
    replaceProps(
      rx.core.Tools.merge(descr.props, partialProps),
      callback
    );
  }

  public function replaceProps(props:rx.core.Descriptor.Props, callback: Dynamic) {
    if (!isMounted()) throw 'Can only update a mounted component';
    if (mountDepth != null) throw 'You called `setProps` or `replaceProps` on a component with a parent.';

    var descr = pendingDescriptor;
    if (descr == null) descr = this.descriptor;

    this.pendingDescriptor = rx.core.Descriptor.cloneAndReplaceProps(descr, props);
    rx.core.Updates.enqueueUpdate(this, callback);
  }

  public function new(descriptor: rx.core.Descriptor) {
    
    this.children = descriptor.children;
    this.props = descriptor.props;
    this.descriptor = descriptor;

    this.context = rx.core.Context.current;
    this.owner = rx.core.Owner.current;

    this.lifecycleState = Lifecycle.Unmounted;
    this.pendingCallbacks = null;

    this.pendingDescriptor = null;

  }

  public function mountComponent(rootId: String, transaction: rx.browser.ReconcileTransaction, mountDepth: Int):String {
    return null;
  }

  public function performUpdateIfNecessary() {

  }
}