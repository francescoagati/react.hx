package rx.browser;

class EventEmitter {
  public inline static function putListener(rootNodeId: String, propKey: String, propVal:Dynamic):Void {
    trace('EventEmitter.putListener');
  }

  public static var registrationNameModules = rx.event.EventPluginHub.registrationNameModules;
}
