package rx.browser.ui;

class Mount {
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