package rx.browser.ui.dom;

class Helper {
  public static inline function field(obj:Dynamic,name: String):Dynamic return untyped obj[name];
}


class Check {
  public static inline var MUST_USE_ATTRIBUTE = 0x1;
  public static inline var MUST_USE_PROPERTY = 0x2;
  public static inline var HAS_BOOLEAN_VALUE = 0x4;
  public static inline var HAS_SIDE_EFFECTS = 0x8;
  public static inline var HAS_POSITIVE_NUMERIC_VALUE = 0x10;

  public static var Properties: Dynamic;
  public static var DOMAttributeNames: Dynamic;
  public static var DOMPropertyNames: Dynamic;

  public inline static function __init__() {
    Properties = {
      /**
       * Standard Properties
       */
      accept: null,
      accessKey: null,
      action: null,
      allowFullScreen: MUST_USE_ATTRIBUTE | HAS_BOOLEAN_VALUE,
      allowTransparency: MUST_USE_ATTRIBUTE,
      alt: null,
      async: HAS_BOOLEAN_VALUE,
      autoComplete: null,
      // autoFocus is polyfilled/normalized by AutoFocusMixin
      // autoFocus: HAS_BOOLEAN_VALUE,
      autoPlay: HAS_BOOLEAN_VALUE,
      cellPadding: null,
      cellSpacing: null,
      charSet: MUST_USE_ATTRIBUTE,
      checked: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      className: MUST_USE_PROPERTY,
      cols: MUST_USE_ATTRIBUTE | HAS_POSITIVE_NUMERIC_VALUE,
      colSpan: null,
      content: null,
      contentEditable: null,
      contextMenu: MUST_USE_ATTRIBUTE,
      controls: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      crossOrigin: null,
      data: null, // For `<object />` acts as `src`.
      dateTime: MUST_USE_ATTRIBUTE,
      defer: HAS_BOOLEAN_VALUE,
      dir: null,
      disabled: MUST_USE_ATTRIBUTE | HAS_BOOLEAN_VALUE,
      download: null,
      draggable: null,
      encType: null,
      form: MUST_USE_ATTRIBUTE,
      formNoValidate: HAS_BOOLEAN_VALUE,
      frameBorder: MUST_USE_ATTRIBUTE,
      height: MUST_USE_ATTRIBUTE,
      hidden: MUST_USE_ATTRIBUTE | HAS_BOOLEAN_VALUE,
      href: null,
      hrefLang: null,
      htmlFor: null,
      httpEquiv: null,
      icon: null,
      id: MUST_USE_PROPERTY,
      label: null,
      lang: null,
      list: null,
      loop: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      max: null,
      maxLength: MUST_USE_ATTRIBUTE,
      mediaGroup: null,
      method: null,
      min: null,
      multiple: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      muted: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      name: null,
      noValidate: HAS_BOOLEAN_VALUE,
      pattern: null,
      placeholder: null,
      poster: null,
      preload: null,
      radioGroup: null,
      readOnly: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      rel: null,
      required: HAS_BOOLEAN_VALUE,
      role: MUST_USE_ATTRIBUTE,
      rows: MUST_USE_ATTRIBUTE | HAS_POSITIVE_NUMERIC_VALUE,
      rowSpan: null,
      sandbox: null,
      scope: null,
      scrollLeft: MUST_USE_PROPERTY,
      scrollTop: MUST_USE_PROPERTY,
      seamless: MUST_USE_ATTRIBUTE | HAS_BOOLEAN_VALUE,
      selected: MUST_USE_PROPERTY | HAS_BOOLEAN_VALUE,
      size: MUST_USE_ATTRIBUTE | HAS_POSITIVE_NUMERIC_VALUE,
      span: HAS_POSITIVE_NUMERIC_VALUE,
      spellCheck: null,
      src: null,
      srcDoc: MUST_USE_PROPERTY,
      step: null,
      style: null,
      tabIndex: null,
      target: null,
      title: null,
      type: null,
      value: MUST_USE_PROPERTY | HAS_SIDE_EFFECTS,
      width: MUST_USE_ATTRIBUTE,
      wmode: MUST_USE_ATTRIBUTE,

      /**
       * Non-standard Properties
       */
      autoCapitalize: null, // Supported in Mobile Safari for keyboard hints
      autoCorrect: null, // Supported in Mobile Safari for keyboard hints
      property: null, // Supports OG in meta tags

      /**
       * SVG Properties
       */
      cx: MUST_USE_ATTRIBUTE,
      cy: MUST_USE_ATTRIBUTE,
      d: MUST_USE_ATTRIBUTE,
      fill: MUST_USE_ATTRIBUTE,
      fx: MUST_USE_ATTRIBUTE,
      fy: MUST_USE_ATTRIBUTE,
      gradientTransform: MUST_USE_ATTRIBUTE,
      gradientUnits: MUST_USE_ATTRIBUTE,
      offset: MUST_USE_ATTRIBUTE,
      points: MUST_USE_ATTRIBUTE,
      r: MUST_USE_ATTRIBUTE,
      rx: MUST_USE_ATTRIBUTE,
      ry: MUST_USE_ATTRIBUTE,
      spreadMethod: MUST_USE_ATTRIBUTE,
      stopColor: MUST_USE_ATTRIBUTE,
      stopOpacity: MUST_USE_ATTRIBUTE,
      stroke: MUST_USE_ATTRIBUTE,
      strokeLinecap: MUST_USE_ATTRIBUTE,
      strokeWidth: MUST_USE_ATTRIBUTE,
      transform: MUST_USE_ATTRIBUTE,
      version: MUST_USE_ATTRIBUTE,
      viewBox: MUST_USE_ATTRIBUTE,
      x1: MUST_USE_ATTRIBUTE,
      x2: MUST_USE_ATTRIBUTE,
      x: MUST_USE_ATTRIBUTE,
      y1: MUST_USE_ATTRIBUTE,
      y2: MUST_USE_ATTRIBUTE,
      y: MUST_USE_ATTRIBUTE
    };

    DOMAttributeNames = {
      className: 'class',
      gradientTransform: 'gradientTransform',
      gradientUnits: 'gradientUnits',
      htmlFor: 'for',
      spreadMethod: 'spreadMethod',
      stopColor: 'stop-color',
      stopOpacity: 'stop-opacity',
      strokeLinecap: 'stroke-linecap',
      strokeWidth: 'stroke-width',
      viewBox: 'viewBox'
    };

    DOMPropertyNames = {
      autoCapitalize: 'autocapitalize',
      autoComplete: 'autocomplete',
      autoCorrect: 'autocorrect',
      autoFocus: 'autofocus',
      autoPlay: 'autoplay',
      encType: 'enctype',
      hrefLang: 'hreflang',
      radioGroup: 'radiogroup',
      spellCheck: 'spellcheck',
      srcDoc: 'srcdoc'
    };
  }
}

class Property {

  public static inline var ID_ATTRIBUTE_NAME = 'data-rxid';

  public inline static function isStandardName(name: String) {
    return Property.Helper.field(Check.Properties, name) != null;
  }

  public inline static function getMutationMethod(name: String): Dynamic {
    return null;
  }

  public inline static function mustUseAttributeName(name: String):Bool {
    return cast (Property.Helper.field(Check.Properties,name) & Check.MUST_USE_ATTRIBUTE);
  }

  public inline static function getAttributeName(name: String): String {
    return Property.Helper.field(Check.DOMAttributeNames,name);
  }

  public inline static function getPropertyName(name: String): String {
    return Property.Helper.field(Check.DOMPropertyNames,name);
  }

  public inline static function hasSideEffects(name: String): Bool {
    return cast (Property.Helper.field(Check.Properties,name) & Check.HAS_SIDE_EFFECTS);
  } 

  public inline static function isCustomAttribute(name: String): Bool {
    return name.indexOf('data-') == 0 || name.indexOf('area-') == 0;
  }

  public inline static function hasBooleanValue(name: String): Bool {
    return cast (Property.Helper.field(Check.MUST_USE_ATTRIBUTE, name) & Check.HAS_BOOLEAN_VALUE);
  }

  public inline static function hasPositiveNumbericValue(name: String): Bool {
    return cast (Property.Helper.field(Check.MUST_USE_ATTRIBUTE, name) & Check.HAS_POSITIVE_NUMERIC_VALUE);
  }

  static var defaultValueCache: rx.core.Props = {};
  public inline static function getDefaultValueForProperty(nodeName: String, prop: String) {
    var nodeDefaults:rx.core.Props = defaultValueCache.get(nodeName);
    var testElement;
    if (nodeDefaults == null) {
      nodeDefaults = {};
      defaultValueCache.set(nodeName, nodeDefaults);
    }
    if (!nodeDefaults.exists(prop)) {
      testElement = js.Browser.document.createElement(nodeName);
      nodeDefaults.set(prop, Property.Helper.field(testElement, prop));
    }
    return nodeDefaults.get(prop);
  }


}
