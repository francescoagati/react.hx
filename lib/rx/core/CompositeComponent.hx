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

  private var renderedComponent: Dynamic;

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
  
}