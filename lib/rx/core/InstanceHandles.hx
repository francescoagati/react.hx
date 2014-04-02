package rx.core;

import rx.browser.RootIndex;

class InstanceHandles {

  public static var SEPARATOR = '.';
  public static function getReactRootIdString(index:Int):String {
    return untyped SEPARATOR + index.toString(36);
  }

  public static function createReactRootId():String {
    return getReactRootIdString(RootIndex.createReactRootIndex());
  }

  public static function createReactID(rootId:String, name:String):String {
    return rootId + name;
  }

  public static function getReactRootIdFromNodeId(id:String) {
    if (id != null && id.charAt(0) == SEPARATOR && id.length > 1) {
      var index = id.indexOf(SEPARATOR, 1);
      return index > -1 ? id.substr(0, index) : id;
    }
    return null;
  }

}