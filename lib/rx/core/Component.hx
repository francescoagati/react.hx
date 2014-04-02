package rx.core;

enum Lifecycle {
  Mounted;
  Unmounted;
}

class Component extends rx.core.Owner {
  
  public var props: rx.core.Descriptor.Props;
  public var children: Array<rx.core.Component>;
  public var context: rx.core.Context;
  public var owner: rx.core.Owner;
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
    super();
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
    var props = this.props;
    if (props != null && props.get('ref') != null) {
      var owner = this.owner;
      Owner.addComponentAsRefTo(this, props.get('ref'), owner);
    }
    this.rootNodeId = rootId;
    this.lifecycleState = Lifecycle.Mounted;
    this.mountDepth = mountDepth;
    return null;
  }

  public function _mountComponentIntoNode(rootId:String, container:js.html.Element, transaction: rx.browser.ReconcileTransaction, shouldReuseMarkup:Bool) {
    var markup = mountComponent(rootId, transaction, 0);
    rx.browser.ui.Environment.mountImageIntoNode(markup, container, shouldReuseMarkup);
  }

  public function mountComponentIntoNode(rootId, container, shouldReuseMarkup) {
    var transaction = rx.browser.ReconcileTransaction.pool.getPooled();
    transaction.perform(
      _mountComponentIntoNode,
      this, [rootId, container, transaction, shouldReuseMarkup]
    );
    rx.browser.ReconcileTransaction.pool.release(transaction);
  }

  public function performUpdateIfNecessary() {

  }
}