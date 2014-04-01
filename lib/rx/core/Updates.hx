package rx.core;

class Updates {
  
  public static var dirtyComponents: Array<rx.core.Component> = new Array<rx.core.Component>();

  public static function enqueueUpdate(component: rx.core.Component, callback: Dynamic):Void {
    
    if (!rx.core.BatchingStrategy.isBatchingUpdates) {
      component.performUpdateIfNecessary();
      if (callback != null) Reflect.callMethod(component, callback, []);
      return;
    }

    dirtyComponents.push(component);

    if (callback != null) {
      if (component.pendingCallbacks != null) {
        component.pendingCallbacks.push(callback);
      } else {
        component.pendingCallbacks = [callback];
      }
    }
  }

  public static function clearDirtyComponents() {
    dirtyComponents = new Array<rx.core.Component>();
  }


  public static function runBatchedUpdates() {
    dirtyComponents.sort(function (c1: rx.core.Component, c2: rx.core.Component) {
      return c1.mountDepth - c2.mountDepth;
    });

    for (component in dirtyComponents) {
      if (component.isMounted()) {
        var callbacks = component.pendingCallbacks;
        component.pendingCallbacks = null;
        component.performUpdateIfNecessary();
        if (callbacks != null) {
          for (callback in callbacks) {
            Reflect.callMethod(component, callback, []);
          }
        }
      }
    }
  }

  public static function flushBatchedUpdates() {
    try {
      runBatchedUpdates();
    } catch(e:Dynamic) {}
    clearDirtyComponents();
  }

  public static function batchedUpdates(callback: Dynamic, param:Dynamic) {
    BatchingStrategy.batchUpdates(callback, param);
  }

}