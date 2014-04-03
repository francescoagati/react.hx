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

  public static function getParentId(id: String, _) {
    return (id != null) ? id.substring(0, id.lastIndexOf(SEPARATOR)) : '';
  }

  public static function isValidId(id: String) {
    return id == '' || (id.charAt(0) == SEPARATOR && id.charAt(id.length - 1) != SEPARATOR);
  }

  public static function getNextDescendantId(ancestorId: String, destinationId: String) {
    // untyped __js__('debugger');
    if (!isValidId(ancestorId) || !isValidId(destinationId)) 
      throw 'getNextDescendantId($ancestorId, $destinationId): Received an invalid DOM ID.';
    if (!isAncestorIdOf(ancestorId, destinationId))
      throw 'getNextDescendantId($ancestorId, $destinationId): React has made an invalid assumption about the DOM hierarchy..';
    if (ancestorId == destinationId) return ancestorId;

    var start = ancestorId.length + SEPARATOR.length;
    var _i = null;
    for (i in start...destinationId.length) {
      if (isBoundary(destinationId, i)) {
        _i = i; break;
      }
    }
    return destinationId.substr(0, _i);
  }

  public static var MAX_TREE_DEPTH = 100;
  public static function traverseParentPath(start: String, stop: String, cb: Dynamic, arg: Dynamic, skipFirst: Bool, skipLast: Bool) {
    if (start == null) start = '';
    if (stop == null) stop = '';
    if (start == stop) throw 'traverseParentPath(...): Cannot traverse from and to the same ID, $start';
    var traverseUp = isAncestorIdOf(stop ,start);
    if (!traverseUp && !isAncestorIdOf(start, stop)) {
      throw 'traverseParentPath($start, $stop, ...): Cannot traverse from two IDs that do not have a parent path';
    }
    var depth = 0;
    var traverse = traverseUp? getParentId : getNextDescendantId;
    var id = start;
    while (true) {
      var ret = null;

      id = traverse(id, stop);
      
      if ((!skipFirst || id != start) && (!skipLast || id!= stop)) {
        ret = cb(id, traverseUp, arg);
      }
      if (ret == false || id == stop) {
        break;
      }
      if (depth++ >= MAX_TREE_DEPTH) throw 'traverseParentPath($start, $stop, ...): Detected an infinite loop while traversing';
    }
  }

  public static function traverseAncestors(targetId: String, cb: Dynamic, ?arg: Dynamic = null) {
    traverseParentPath('', targetId, cb, arg, true, false);
  }

  public static function isBoundary(id: String, index: Int): Bool {
    return id.charAt(index) == SEPARATOR || index == id.length;
  }

  public static function isAncestorIdOf(ancestorId:String, descendantId:String):Bool {
    return (descendantId.indexOf(ancestorId) == 0 && isBoundary(descendantId, ancestorId.length));
  }

}