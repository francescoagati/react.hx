package rx.browser.ui;

class Mount {

  public static var totalInstantiationTime: Int = 0;
  public static var totalInjectionTime: Int = 0;

  public static function scrollMonitor(container: js.html.Element, renderCallback: Dynamic) {
    renderCallback();
  }

  public static inline var DOC_NODE_TYPE:Int = 9;
  public static function getReactRootElementInContainer(container: js.html.Element): js.html.Node {
    if (container == null) {
      return null;
    }
    if (container.nodeType == DOC_NODE_TYPE) {
      return js.Browser.document.documentElement;
    } else {
      return container.firstChild;
    }
  }

  public static function internalGetId(node: js.html.Node):String {
    var id = '';
    if (Reflect.hasField(node, 'getAttribute') != null) {
      id = Reflect.callMethod(node, Reflect.getProperty(node, 'getAttribute'), [rx.browser.ui.dom.Property.ID_ATTRIBUTE_NAME]);
    }
    return id;
  }

  public static function getId(node: js.html.Node):String {
    var id = internalGetId(node);
    // TODO: node cache
    return id;
  }

  public static function getReactRootId(container: js.html.Element):String {
    var rootElement = getReactRootElementInContainer(container);
    if (rootElement != null) return getId(rootElement);
    return null;
  }

  public static function getInstanceByContainer(container: js.html.Element):rx.core.Component {
    var id:String = getReactRootId(container);
    return instancesByReactRootId.get(id);
  }

  public static function shouldUpdateReactComponent(prev: rx.core.Component, next: rx.core.Component):Bool {
    if (
      (prev != null && next != null) && 
      (Type.getClass(prev) == Type.getClass(next)) &&
      (prev.descriptor.props.get('key') == next.descriptor.props.get('key')) &&
      (prev.owner == next.owner)) {
      return true;
    }
    return false;
  }

  public static function updateRootComponent(prev: rx.core.Component, next: rx.core.Component, container: js.html.Element, callback:Dynamic):rx.core.Component {
    var nextProps = next.props;
    scrollMonitor(container, function () {
      prev.replaceProps(nextProps, callback);
    });
    return prev;
  }

  public static function unmountComponentAtNode(container: js.html.Element) {

  }

  public static var containersByReactRootId = new Map<String, js.html.Element>();
  public static function registerContainer(container: js.html.Element):String {
    var reactRootId = getReactRootId(container);
    if (reactRootId != null) {
      // If one exists, make sure it is a valid "reactRoot" ID.
      reactRootId = rx.core.InstanceHandles.getReactRootIdFromNodeId(reactRootId);
    }
    if (reactRootId == null) {
      // No valid "reactRoot" ID found, create one.
      reactRootId = rx.core.InstanceHandles.createReactRootId();
    }
    containersByReactRootId.set(reactRootId, container);
    return reactRootId;
  }

  public static function registerComponent(component: rx.core.Component, container:js.html.Element):String {
    var reactRootId = registerContainer(container);
    instancesByReactRootId.set(reactRootId, component);
    return reactRootId; 
  }

  public static function renderNewRootComponent(component: rx.core.Component, container: js.html.Element, shouldReuseMarkup: Bool):rx.core.Component {
    var reactRootId = registerComponent(component, container);
    component.mountComponentIntoNode(reactRootId, container, shouldReuseMarkup);
    return component;
  }

  public static inline var SEPARATOR:String = '.';
  public static function isRenderedByReact(node: js.html.Node):Bool {
    if (node.nodeType != 1) {
      // Not a DOMElement, therefore not a React component
      return false;
    }
    var id = getId(node);
    return (id != null) ? id.charAt(0) == SEPARATOR : false;
  }

  public static var instancesByReactRootId = new Map<String, rx.core.Component>();
  public static function renderComponent(component: rx.core.Component, container: js.html.Element, ?callback: Dynamic) {
    var prevComponent = getInstanceByContainer(container);
    if (prevComponent != null) {
      var prevDescriptor = prevComponent.descriptor;
      var nextDescriptor = component.descriptor;
      if (shouldUpdateReactComponent(prevComponent, component)) {
        return updateRootComponent(prevComponent, component, container, callback);
      } else {
        unmountComponentAtNode(container);
      }
    }

    var reactRootElement = getReactRootElementInContainer(container);
    var containerHasReactMarkup = (reactRootElement != null && isRenderedByReact(reactRootElement));
    var shouldReuseMarkup = containerHasReactMarkup && (prevComponent == null);

    var component = renderNewRootComponent(component, container, shouldReuseMarkup);
    return component;
  } 
   
  /*
  static var instancesByReactRootId: Map<String, Component> = new Map<String,Component>();

  public static function internalGetId(node: js.html.Node):String {
    var id = '';
    if (Reflect.hasField(node, 'getAttribute') != null) {
      id = Reflect.callMethod(node, Reflect.getProperty(node, 'getAttribute'), [rx.DomProperty.ID_ATTRIBUTE_NAME]);
    }
    return id;
  }

  public static function getId(node: js.html.Node):String {
    var id = internalGetId(node);
    // TODO: node cache
    return id;
  }

  public static inline var DOC_NODE_TYPE:Int = 9;

  public static function getReactRootElementInContainer(container: js.html.Element): js.html.Node {
    if (container == null) {
      return null;
    }
    if (container.nodeType == DOC_NODE_TYPE) {
      return js.Browser.document.documentElement;
    } else {
      return container.firstChild;
    }
  }

  public static function getReactRootId(container: js.html.Element):String {
    var rootElement = getReactRootElementInContainer(container);
    if (rootElement != null) return getId(rootElement);
    return null;
  }

  public static function getInstanceByContainer(container: js.html.Element):Component {
    var id:String = getReactRootId(container);
    return instancesByReactRootId[id];
  }

  public static inline var SEPARATOR:String = '.'
;  public static function isRenderedByReact(node: js.html.Node):Bool {
    if (node.nodeType != 1) {
      // Not a DOMElement, therefore not a React component
      return false;
    }
    var id = getId(node);
    return (id != null) ? id.charAt(0) == SEPARATOR : false;
  }

  public static function instantiateReactComponent(cmpClass: Class<Component>):Component {
    return Type.createInstance(cmpClass, []);
  }

  public static function registerComponent(instance:Component, container: js.html.Element):String {
    return null;
  }

  public static function renderNewRootComponent(cmpClass: Class<Component>, container: js.html.Element, shouldReuseMarkup: Bool) {
    var instance = instantiateReactComponent(cmpClass);
    var reactRootId = registerComponent(instance,container);
    instance.mountComponentIntoNode(reactRootId, container, shouldReuseMarkup);
    return instance;
  }

  public static function renderComponent(cmpClass: Class<Component>, container: js.html.Element):Component {

    var prevComponent = getInstanceByContainer(container);
    if (prevComponent != null) {
      // todo: check if need update
      return prevComponent;
    }

    var reactRootElement = getReactRootElementInContainer(container);
    var containerHasReactMarkup = (reactRootElement != null) && isRenderedByReact(reactRootElement);
    var shouldReuseMarkup = containerHasReactMarkup && (prevComponent == null);

    var cmp = renderNewRootComponent(cmpClass, container, shouldReuseMarkup);
    return cmp;
  }
  */
}