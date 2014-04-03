package rx.core;

enum CompositeLifecycle {
  Mounting;
  Unmounting;
  ReceivingProps;
  ReceivingState;
}

class CompositeComponent<T> extends rx.core.Component {

  private var compositeLifecycleState: CompositeLifecycle;

  private var state: T;
  private var pendingState: T;
  private var pendingForceUpdate: Bool;
  private var defaultProps: rx.core.Descriptor.Props;

  private var renderedComponent: rx.core.Component;

  public function new() {
    super(new rx.core.Descriptor(null, null));

    state = null;
    pendingState = null;
    pendingForceUpdate = false;
    context = null;
    compositeLifecycleState = null;

  }
  public override function isMounted():Bool {
    return super.isMounted();
  }

  public function getInitialState():T {
    return null;
  }

  public function getDefaultProps():rx.core.Descriptor.Props {
    return null;
  }

  public function componentWillMount():Void {}
  public function componentDidMount():Void {}

  public function componentWillUpdate(props, state, context):Void {}
  public function componentDidUpdate(props, state, context):Void {}

  public function render():rx.core.Component { return null; }

  private function renderValidatedComponent():rx.core.Component {

    var renderedComponent = null;
    // var previousContext = Context.current;
    // Context.current = processChildContext(this.descriptor.context);
    rx.core.Owner.current = this;
    try {
      renderedComponent = this.render();
    } catch(e:Dynamic) {}
    // Context.current = prev;
    rx.core.Owner.current = null;

    return renderedComponent;
  }

  public override function mountComponent(rootId: String, transaction: rx.browser.ReconcileTransaction, mountDepth:Int):String {

    super.mountComponent(rootId, transaction, mountDepth);
    compositeLifecycleState = CompositeLifecycle.Mounting;

    // context = processContext(context);
    defaultProps = getDefaultProps();
    // props = processProps(props);

    state = getInitialState();
    pendingState = null;
    pendingForceUpdate = false;

    componentWillMount();
    if (pendingState != null) {
      state = pendingState;
      pendingState = null;
    }

    renderedComponent = renderValidatedComponent();

    compositeLifecycleState = null;

    var markup = renderedComponent.mountComponent(rootId, transaction, mountDepth + 1);
    transaction.getMountReady().enqueue(this, componentDidMount);
    return markup;
  }

  public function digest(?callback: Dynamic) {
    rx.core.Updates.enqueueUpdate(this, callback);
  }

  public override function receiveComponent(nextComponent:rx.core.Component, transaction:rx.browser.ReconcileTransaction) {
    if (nextComponent.descriptor == this.descriptor && nextComponent.owner != null) {
      // Since props and context are immutable after the component is
      // mounted, we can do a cheap identity compare here to determine
      // if this is a superfluous reconcile.
      return;
    }
    
    super.receiveComponent(
      nextComponent,
      transaction
    );
  }

  public override function updateComponent(
    transaction:rx.browser.ReconcileTransaction, 
    prevProps:rx.core.Descriptor.Props, 
    prevOwner: rx.core.Owner, 
    ?prevState: Dynamic, 
    ?prevContext: Dynamic) {

    super.updateComponent(transaction, prevProps, prevOwner);

    var prevComponent = renderedComponent;
    var nextComponent = renderValidatedComponent();

    if (rx.core.Component.shouldUpdate(prevComponent, nextComponent)) {
      prevComponent.receiveComponent(nextComponent, transaction);
    } else {
      
      var thisId = rootNodeId;
      var prevComponentId = prevComponent.rootNodeId;
      prevComponent.unmountComponent();
      var nextMarkup = renderedComponent.mountComponent(thisId, transaction, mountDepth + 1);

      rx.browser.ui.dom.IdOperations.dangerouslyReplaceNodeWithMarkupById(prevComponentId, nextMarkup);
    }

  }

  public function _performComponentUpdate(
    nextProps: rx.core.Descriptor.Props,
    nextOwner: rx.core.Owner,
    nextState: T,
    nextFullContext: rx.core.Context,
    nextContext: rx.core.Context,
    transaction: rx.browser.ReconcileTransaction) {

    this.componentWillUpdate(nextProps, nextState, nextContext);

    this.updateComponent(
      transaction,
      // prevProps,
      // prevOwner,
      // prevState,
      // prevContext
      props,
      owner,
      state,
      context
    );

    transaction.getMountReady().enqueue(this, componentDidUpdate, [props, state, context]);

  }

  public override function _performUpdateIfNecessary(transaction: rx.browser.ReconcileTransaction) {
    // if (this._pendingProps == null &&
    //     this._pendingState == null &&
    //     this._pendingContext == null &&
    //     !this._pendingForceUpdate) {
    //   return;
    // }

    // var nextFullContext = this._pendingContext || this._currentContext;
    // var nextContext = this._processContext(nextFullContext);
    // this._pendingContext = null;

    // var nextProps = this.props;
    // if (this._pendingProps != null) {
    //   nextProps = this._processProps(this._pendingProps);
    //   this._pendingProps = null;

    //   this._compositeLifeCycleState = CompositeLifeCycle.RECEIVING_PROPS;
    //   if (this.componentWillReceiveProps) {
    //     this.componentWillReceiveProps(nextProps, nextContext);
    //   }
    // }

    compositeLifecycleState = CompositeLifecycle.ReceivingState;

    // var nextOwner = this._pendingOwner;
    // var nextState = this._pendingState || this.state;
    // this._pendingState = null;

    try {

      this._performComponentUpdate(
        props,
        owner,
        state,
        context,
        context,
        transaction
      );

    } catch(e:Dynamic) {
      trace(e);
    }

    compositeLifecycleState = null;
  }

  public override function performUpdateIfNecessary() {
    var _state = compositeLifecycleState;
    if (_state == CompositeLifecycle.Mounting || _state == CompositeLifecycle.ReceivingProps) {
      return;
    } 
    return super.performUpdateIfNecessary();
  }
  
}