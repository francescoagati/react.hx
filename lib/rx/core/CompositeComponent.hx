package rx.core;

typedef Props = Dynamic;

enum CompositeLifecycle {
  Mounting;
  Unmounting;
  ReceivingProps;
  ReceivingState;
}

class CompositeComponent extends rx.core.Component {
/*
  private var compositeLifecycleState: CompositeLifecycle;

  private var state: T1;
  private var pendingState: T1;
  private var pendingForceUpdate: Bool;
  private var context: Dynamic; // ?
  private var defaultProps: T2;

  private var renderedComponent: Dynamic;

  public function new(?children: Array<Component>, ?props: T2) {
    super();

    state = null;
    pendingState = null;
    pendingForceUpdate = false;
    context = null;
    compositeLifecycleState = null;

  }
  public override function isMounted():Bool {
    return super.isMounted();
  }

  public function getInitialState():T1 {
    return null;
  }

  public function getDefaultProps():T2 {
    return null;
  }

  public function componentWillMount():Void {}
  public function componentDidMount():Void {}

  public function render():rx.Component { return null; }

  private function renderValidatedComponent():rx.Component {

    var renderedComponent = null;
    // var previousContext = Context.current;
    // Context.current = processChildContext(this.descriptor.context);
    React.CurrentOwner = this;
    try {
      renderedComponent = this.render();
    } catch(e:Dynamic) {}
    // Context.current = prev;
    React.CurrentOwner = null;

    return renderedComponent;
  }

  public override function mountComponent(rootId: String, transaction: rx.ReconcileTransaction, ?mountDepth:Int = 0):String {

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
  */
}