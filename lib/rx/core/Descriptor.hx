package rx.core;

typedef Props = Map<String, Dynamic>;

class Descriptor {
  public static function cloneAndReplaceProps(oldDescriptor: Descriptor, newProps: Props) {
    var newDescriptor = new Descriptor(oldDescriptor.children, oldDescriptor.props);
    newDescriptor.props = newProps;
    return newDescriptor;
  }

  public var children: Array<rx.core.Component>;
  public var props: Props;

  public function new(children: Array<rx.core.Component>, props: Props) {
    this.children = children;
    this.props = props;
  }
}