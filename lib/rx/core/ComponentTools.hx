package rx.core;
import rx.core.*;
import rx.browser.*;

class ComponentTools {

  public static inline  function ext_mountComponent(component:Component,rootId: String, transaction: ReconcileTransaction, mountDepth: Int):String {
    var props = component.props;
    if (props != null && props.get('ref') != null) {
      var owner = component.owner;
      Owner.addComponentAsRefTo(component, props.get('ref'), owner);
    }
    component.rootNodeId = rootId;
    component.lifecycleState = Mounted;
    component.mountDepth = mountDepth;
    return null;
  }

}
