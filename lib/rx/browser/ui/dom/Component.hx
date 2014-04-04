package rx.browser.ui.dom;

import rx.core.Component;
import rx.core.ContainerComponent;
import rx.core.Props;
import rx.core.Owner;

import rx.browser.ReconcileTransaction;

import rx.browser.ui.dom.Property in DomProperty;
import rx.browser.ui.dom.IdOperations;

class Component extends ContainerComponent {
  var tagOpen: String;
  var tagClose: String;
  var omitClose: Bool;
  public function new(tagName: String, omitClose: Bool, descriptor: rx.core.Descriptor) {
    super(descriptor);
    this.tagOpen = '<$tagName';
    this.tagClose = omitClose ? '' : '</$tagName>';
  }

  public override function mountComponent(rootId: String, transaction: ReconcileTransaction, mountDepth: Int):String {
    super.mountComponent(rootId, transaction, mountDepth);
    return (
      createOpenTagMarkupAndPutListeners(transaction) +
      createContentMarkup(transaction) +
      tagClose
    );
  }

  private static var ELEMENT_NODE_TYPE = 1;
  private function putListener(id: String, registrationName: String, listener: Dynamic, transaction: ReconcileTransaction) {
    var container = rx.browser.ui.Mount.findReactContainerForId(id);
    if (container != null) {
      var doc = container.nodeType == ELEMENT_NODE_TYPE ?
        container.ownerDocument :
        container;
      // listenTo(registrationName, doc);
      trace('listenTo: registrationName');
    }
    transaction.getPutListenerQueue().enqueuePutListener(id, registrationName, listener);
  }

  public function createOpenTagMarkupAndPutListeners(transaction: ReconcileTransaction):String {
    var props = this.props;
    var ret = this.tagOpen;
    if (props != null) {
      for (propKey in props.keys()) {

        var propValue = props.get(propKey);

        if (propValue == null) {
          continue;
        }

        if (rx.browser.EventEmitter.registrationNameModules.exists(propKey)) {
          putListener(this.rootNodeId, propKey, propValue, transaction);
        } else {
          // if (propKey == STYLE) {
          //   if (propValue != null) {
          //     propValue = props.style = rx.core.Tools.merge(props.style, null);
          //   }
          //   propValue = CSSPropertyOperations.createMarkupForStyles(propValue);
          // }
          var markup = PropertyOperations.createMarkupForProperty(propKey, propValue);
          if (markup != '' && markup != null) {
            ret += ' ' + markup;
          }
        }
      }
    }

    if (transaction.renderToStaticMarkup) {
      return ret + '>';
    }

    var markupForId = PropertyOperations.createMarkupForId(rootNodeId);
    return ret + ' ' + markupForId + '>';
  }

  public function createContentMarkup(transaction: ReconcileTransaction) {
    var children = this.props.get('children');
    var mountImages = this.mountChildren(children, transaction);
    return mountImages.join('');
  }

  public override function updateComponent(
    transaction: ReconcileTransaction,
    props: Props,
    owner: Owner,
    ?prevProps: Props,
    ?prevOwner: Owner,
    ?prevChildren: Array<rx.core.Component>) {

    super.updateComponent(transaction, props, owner);
    _updateDOMProperties(props, transaction);
    _updateDOMChildren(props, transaction);

  }

  public function _updateDOMProperties(lastProps: Props, transaction: ReconcileTransaction) {
    var nextProps = this.props;

    var styleName = null;
    var styleUpdates = null;

    if (lastProps == null) return;

    for (propKey in lastProps.keys()) {
      if (nextProps.exists(propKey)) {
        continue;
      }
      if (propKey == 'azaza') {

      } else if (rx.browser.EventEmitter.registrationNameModules.get(propKey)) {

      } else if (
        DomProperty.isStandardName(propKey) ||
        DomProperty.isCustomAttribute(propKey)
      ) {
        IdOperations.deletePropertyById(this.rootNodeId, propKey);
      }
    }

    for (propKey in nextProps.keys()) {
      var nextProp = nextProps.get(propKey);
      var lastProp = lastProps.get(propKey);

      if (nextProp == lastProp) continue;
      if (propKey == 'style') {

      } else if (rx.browser.EventEmitter.registrationNameModules.get(propKey)) {

      } else if (
        DomProperty.isStandardName(propKey) ||
        DomProperty.isCustomAttribute(propKey)
      ) {
        IdOperations.updatePropertyById(this.rootNodeId, propKey, nextProp);
      }
    }
  }

  public function _updateDOMChildren(lastProps: Props, transaction: ReconcileTransaction) {
    var nextProps = this.props;
    var lastChildren = lastProps.get('children');
    var nextChildren = nextProps.get('children');

    if (lastChildren != null && nextChildren == null) {
      this.updateChildren(null, transaction);
    } else if (nextChildren != null) {
      this.updateChildren(nextChildren, transaction);
    }


  }
}