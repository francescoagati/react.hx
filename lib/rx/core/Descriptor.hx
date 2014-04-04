package rx.core;

import rx.core.Component;

typedef Props = Map<String, Dynamic>;

class Descriptor {
  public static function cloneAndReplaceProps(oldDescriptor: Descriptor, newProps: Props) {
    var newDescriptor = new Descriptor(oldDescriptor.children, oldDescriptor.props);
    newDescriptor.props = newProps;
    return newDescriptor;
  }

  public var children: Array<Component>;
  public var props: Props;

  public function new(?children: Array<Component> = null, ?props: Props = null) {
    if (children != null)
      this.children = children;
    else this.children = new Array<Component>();

    if (props != null)
      this.props = props;
    else this.props = new Map<String, Dynamic>();

    this.props.set('children', children);
  }
}