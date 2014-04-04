package rx.core;

import rx.core.Component;
import rx.core.Props;

class Descriptor {
  public static function cloneAndReplaceProps(oldDescriptor: Descriptor, newProps: Props) {
    var newDescriptor = new Descriptor(oldDescriptor.props.get('chidren'), oldDescriptor.props);
    newDescriptor.props = newProps;
    return newDescriptor;
  }

  public var props: Props;

  public function new(?children: Array<Component> = null, ?props: Props = null) {

    var c = (children != null) ? children : new Array<Component>();

    if (props != null)
      this.props = props;
    else this.props = {};

    this.props.set('children', c);
  }
}