(function () { "use strict";
var $estr = function() { return js.Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var RootState = function(splitter) {
	this.splitter = " ";
	this.splitter = splitter;
};
RootState.__name__ = true;
RootState.prototype = {
	__class__: RootState
};
var rx = {};
rx.core = {};
rx.core.Owner = function() {
	this.refs = { };
};
rx.core.Owner.__name__ = true;
rx.core.Owner.isValidOwner = function(object) {
	return true;
};
rx.core.Owner.addComponentAsRefTo = function(component,ref,owner) {
	owner.attachRef(ref,component);
};
rx.core.Owner.removeComponentAsRefFrom = function(component,ref,owner) {
	if(owner.refs[ref] == component) owner.detachRef(ref);
};
rx.core.Owner.prototype = {
	attachRef: function(ref,component) {
		if(!component.isOwnedBy(this)) throw "Only a component's owner can store a ref to it.";
		this.refs[ref] = component;
	}
	,detachRef: function(ref) {
		Reflect.deleteField(this.refs,ref);
	}
	,__class__: rx.core.Owner
};
rx.core.Component = function(descriptor) {
	rx.core.Owner.call(this);
	this.children = descriptor.children;
	this.props = descriptor.props;
	this.descriptor = descriptor;
	this.context = rx.core.Context.current;
	this.owner = rx.core.Owner.current;
	this.lifecycleState = rx.core.Lifecycle.Unmounted;
	this.pendingCallbacks = null;
	this.pendingDescriptor = null;
};
rx.core.Component.__name__ = true;
rx.core.Component.shouldUpdate = function(prevComponent,nextComponent) {
	if(prevComponent != null && nextComponent != null && prevComponent.props.key == nextComponent.props.key != null) {
		if(prevComponent.owner == nextComponent.owner) return true;
	}
	return false;
};
rx.core.Component.__super__ = rx.core.Owner;
rx.core.Component.prototype = $extend(rx.core.Owner.prototype,{
	isMounted: function() {
		return this.lifecycleState == rx.core.Lifecycle.Mounted;
	}
	,isOwnedBy: function(owner) {
		return owner == this.owner;
	}
	,setProps: function(partialProps,callback) {
		var descr = this.pendingDescriptor;
		if(descr == null) descr = this.descriptor;
		this.replaceProps(rx.core.Tools.merge(descr.props,partialProps),callback);
	}
	,replaceProps: function(props,callback) {
		if(!this.isMounted()) throw "Can only update a mounted component";
		if(this.mountDepth != null) throw "You called `setProps` or `replaceProps` on a component with a parent.";
		var descr = this.pendingDescriptor;
		if(descr == null) descr = this.descriptor;
		this.pendingDescriptor = rx.core.Descriptor.cloneAndReplaceProps(descr,props);
		rx.core.Updates.enqueueUpdate(this,callback);
	}
	,mountComponent: function(rootId,transaction,mountDepth) {
		var props = this.props;
		if(props != null && props.ref != null) {
			var owner = this.owner;
			rx.core.Owner.addComponentAsRefTo(this,props.ref,owner);
		}
		this.rootNodeId = rootId;
		this.lifecycleState = rx.core.Lifecycle.Mounted;
		this.mountDepth = mountDepth;
		return null;
	}
	,_mountComponentIntoNode: function(rootId,container,transaction,shouldReuseMarkup) {
		var markup = this.mountComponent(rootId,transaction,0);
		rx.browser.ui.Environment.mountImageIntoNode(markup,container,shouldReuseMarkup);
	}
	,mountComponentIntoNode: function(rootId,container,shouldReuseMarkup) {
		var transaction = rx.browser.ReconcileTransaction.pool.getPooled();
		transaction.perform($bind(this,this._mountComponentIntoNode),this,[rootId,container,transaction,shouldReuseMarkup]);
		rx.browser.ReconcileTransaction.pool.release(transaction);
	}
	,receiveComponent: function(nextComponent,transaction) {
		this.pendingOwner = nextComponent.owner;
		this.pendingProps = nextComponent.props;
		this.pendingChildren = nextComponent.children;
		this._performUpdateIfNecessary(transaction);
	}
	,_performUpdateIfNecessary: function(transaction) {
		if(this.pendingProps == null) return;
		var prevProps = this.props;
		var prevOwner = this.owner;
		this.props = this.pendingProps;
		this.owner = this.pendingOwner;
		this.pendingProps = null;
		this.updateComponent(transaction,prevProps,prevOwner);
	}
	,performUpdateIfNecessary: function() {
		var transaction = rx.browser.ReconcileTransaction.pool.getPooled();
		transaction.perform($bind(this,this._performUpdateIfNecessary),this,[transaction]);
		rx.browser.ReconcileTransaction.pool.release(transaction);
	}
	,updateComponent: function(transaction,prevProps,prevOwner,prevState,prevContext,prevChildren) {
		var props = this.props;
		if(this.owner != prevOwner || props.ref != prevProps.ref) {
			if(prevProps != null && prevProps.ref != null) rx.core.Owner.removeComponentAsRefFrom(this,prevProps.ref,prevOwner);
			if(props != null && props.ref != null) rx.core.Owner.addComponentAsRefTo(this,props.ref,this.owner);
		}
	}
	,unmountComponent: function() {
		if(!this.isMounted()) throw "Can only unmount a mounted component.";
		var props = this.props;
		if(props.ref != null) rx.core.Owner.removeComponentAsRefFrom(this,props.ref,this.owner);
		rx.browser.ui.Environment.unmountIdFromEnvironment(this.rootNodeId);
		this.rootNodeId = null;
		this.lifecycleState = rx.core.Lifecycle.Unmounted;
	}
	,__class__: rx.core.Component
});
rx.core.CompositeComponent = function() {
	rx.core.Component.call(this,new rx.core.Descriptor(null,null));
	this.state = null;
	this.pendingState = null;
	this.pendingForceUpdate = false;
	this.context = null;
	this.compositeLifecycleState = null;
};
rx.core.CompositeComponent.__name__ = true;
rx.core.CompositeComponent.__super__ = rx.core.Component;
rx.core.CompositeComponent.prototype = $extend(rx.core.Component.prototype,{
	isMounted: function() {
		return rx.core.Component.prototype.isMounted.call(this);
	}
	,getInitialState: function() {
		return null;
	}
	,getDefaultProps: function() {
		return null;
	}
	,componentWillMount: function() {
	}
	,componentDidMount: function() {
	}
	,componentWillUpdate: function(props,state,context) {
	}
	,componentDidUpdate: function(props,state,context) {
	}
	,componentWillReceiveProps: function(props,context) {
	}
	,shouldComponentUpdate: function(props,state,context) {
		return true;
	}
	,render: function() {
		return null;
	}
	,renderValidatedComponent: function() {
		var renderedComponent = null;
		var previousContext = rx.core.Context.current;
		rx.core.Owner.current = this;
		try {
			renderedComponent = this.render();
		} catch( e ) {
			if( js.Boot.__instanceof(e,Error) ) {
				console.log(e.stack);
			} else throw(e);
		}
		rx.core.Owner.current = null;
		return renderedComponent;
	}
	,mountComponent: function(rootId,transaction,mountDepth) {
		rx.core.Component.prototype.mountComponent.call(this,rootId,transaction,mountDepth);
		this.compositeLifecycleState = rx.core.CompositeLifecycle.Mounting;
		this.defaultProps = this.getDefaultProps();
		this.state = this.getInitialState();
		this.pendingState = null;
		this.pendingForceUpdate = false;
		this.componentWillMount();
		if(this.pendingState != null) {
			this.state = this.pendingState;
			this.pendingState = null;
		}
		this.renderedComponent = this.renderValidatedComponent();
		this.compositeLifecycleState = null;
		var markup = this.renderedComponent.mountComponent(rootId,transaction,mountDepth + 1);
		transaction.getMountReady().enqueue(this,$bind(this,this.componentDidMount));
		return markup;
	}
	,setState: function(state) {
		this.pendingState = state;
		this.digest();
	}
	,digest: function(callback) {
		this.pendingForceUpdate = true;
		rx.core.Updates.enqueueUpdate(this,callback);
	}
	,receiveComponent: function(nextComponent,transaction) {
		if(nextComponent.props == this.props && nextComponent.owner != null) return;
		rx.core.Component.prototype.receiveComponent.call(this,nextComponent,transaction);
	}
	,updateComponent: function(transaction,prevProps,prevOwner,prevState,prevContext,prevChildren) {
		rx.core.Component.prototype.updateComponent.call(this,transaction,prevProps,prevOwner);
		var prevComponent = this.renderedComponent;
		var nextComponent = this.renderValidatedComponent();
		if(rx.core.Component.shouldUpdate(prevComponent,nextComponent)) prevComponent.receiveComponent(nextComponent,transaction); else {
			var thisId = this.rootNodeId;
			var prevComponentId = prevComponent.rootNodeId;
			prevComponent.unmountComponent();
			var nextMarkup = this.renderedComponent.mountComponent(thisId,transaction,this.mountDepth + 1);
			var node = rx.browser.ui.Mount.getNode(prevComponentId);
			rx.browser.ui.dom.Danger.dangerouslyReplaceNodeWithMarkup(node,nextMarkup);
		}
	}
	,_performComponentUpdate: function(nextProps,nextOwner,nextState,nextContext,transaction) {
		this.componentWillUpdate(nextProps,nextState,nextContext);
		var prevProps = this.props;
		var prevState = this.state;
		var prevContext = this.context;
		this.props = nextProps;
		this.owner = nextOwner;
		this.state = nextState;
		this.context = nextContext;
		this.updateComponent(transaction,prevProps,this.owner);
		transaction.getMountReady().enqueue(this,$bind(this,this.componentDidUpdate),[prevProps,prevState,prevContext]);
	}
	,processProps: function(pendingProps) {
		return pendingProps;
	}
	,processContext: function(pendingContext) {
		return pendingContext;
	}
	,_performUpdateIfNecessary: function(transaction) {
		if(this.pendingProps == null && this.pendingState == null && this.pendingContext == null && !this.pendingForceUpdate) return;
		var nextFullContext = this.pendingContext;
		if(nextFullContext == null) nextFullContext = this.context;
		var nextContext = this.processContext(nextFullContext);
		this.pendingContext = null;
		var nextProps = this.props;
		if(this.pendingProps != null) {
			nextProps = this.processProps(this.pendingProps);
			this.pendingProps = null;
			this.compositeLifecycleState = rx.core.CompositeLifecycle.ReceivingProps;
			this.componentWillReceiveProps(nextProps,nextContext);
		}
		this.compositeLifecycleState = rx.core.CompositeLifecycle.ReceivingState;
		var nextOwner = this.pendingOwner;
		var nextState = this.pendingState;
		if(nextState == null) nextState = this.state;
		this.pendingState = null;
		try {
			if(this.pendingForceUpdate || this.shouldComponentUpdate(nextProps,nextState,nextContext)) {
				this.pendingForceUpdate = false;
				this._performComponentUpdate(nextProps,nextOwner,nextState,nextContext,transaction);
			} else {
				this.props = nextProps;
				this.state = nextState;
				this.context = nextContext;
			}
		} catch( e ) {
			if( js.Boot.__instanceof(e,Error) ) {
				console.log(e.stack);
			} else throw(e);
		}
		this.compositeLifecycleState = null;
	}
	,performUpdateIfNecessary: function() {
		var _state = this.compositeLifecycleState;
		if(_state == rx.core.CompositeLifecycle.Mounting || _state == rx.core.CompositeLifecycle.ReceivingProps) return;
		return rx.core.Component.prototype.performUpdateIfNecessary.call(this);
	}
	,__class__: rx.core.CompositeComponent
});
var MyComponent = function() {
	this.fail = 0;
	this.time = new Date().getTime();
	this.c = 0;
	rx.core.CompositeComponent.call(this);
};
MyComponent.__name__ = true;
MyComponent.__super__ = rx.core.CompositeComponent;
MyComponent.prototype = $extend(rx.core.CompositeComponent.prototype,{
	getInitialState: function() {
		return new RootState("Om-nom-nom-nom");
	}
	,componentDidMount: function() {
		var _g = this;
		this.interval = window.setInterval(function() {
			_g.c++;
			_g.setState(new RootState("Ahaha"));
		},0);
	}
	,componentWillUpdate: function(props,state,context) {
		this.time = new Date().getTime();
	}
	,componentDidUpdate: function(props,state,context) {
		var diff = new Date().getTime() - this.time;
		if(diff > 16) {
			this.fail++;
			console.log("Whoops: " + this.c + " - " + diff);
			if(this.fail > 5) window.clearInterval(this.interval);
		}
	}
	,render: function() {
		return rx.browser.ui.DOM.el("div",(function($this) {
			var $r;
			var _g = [];
			{
				var _g2 = 0;
				var _g1 = $this.c;
				while(_g2 < _g1) {
					var i = _g2++;
					_g.push(rx.browser.ui.DOM.el("div",[rx.browser.ui.DOM.text("Hello world " + Std.string($this.c))]));
				}
			}
			$r = _g;
			return $r;
		}(this)));
	}
	,__class__: MyComponent
});
var App = function() { };
App.__name__ = true;
App.main = function() {
	var d = window.document;
	d.addEventListener("DOMContentLoaded",function(event) {
		var container = d.getElementById("app");
		var start = new Date().getTime();
		rx.browser.ui.Mount.renderComponent(new MyComponent(),container);
		window.setTimeout(function() {
			var end = new Date().getTime() - start;
			console.log("Execution time: " + end);
		},0);
	});
};
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.__name__ = true;
EReg.prototype = {
	replace: function(s,by) {
		return s.replace(this.r,by);
	}
	,__class__: EReg
};
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
};
Math.__name__ = true;
var Reflect = function() { };
Reflect.__name__ = true;
Reflect.hasField = function(o,field) {
	return Object.prototype.hasOwnProperty.call(o,field);
};
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
};
Reflect.deleteField = function(o,field) {
	if(!Reflect.hasField(o,field)) return false;
	delete(o[field]);
	return true;
};
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
};
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
};
var Type = function() { };
Type.__name__ = true;
Type.getClass = function(o) {
	if(o == null) return null;
	return o.__class__;
};
var js = {};
js.Boot = function() { };
js.Boot.__name__ = true;
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
};
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) {
					if(cl == Array) return o.__enum__ == null;
					return true;
				}
				if(js.Boot.__interfLoop(o.__class__,cl)) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
rx.event = {};
rx.event.EventPluginRegistry = function() { };
rx.event.EventPluginRegistry.__name__ = true;
rx.event.EventPluginHub = function() { };
rx.event.EventPluginHub.__name__ = true;
rx.browser = {};
rx.browser.EventEmitter = function() { };
rx.browser.EventEmitter.__name__ = true;
rx.browser.EventEmitter.putListener = function(rootNodeId,propKey,propVal) {
	console.log("EventEmitter.putListener");
};
rx.utils = {};
rx.utils.PooledClass_rx_browser_PutListenerQueue = function(poolSize) {
	this.poolSize = 10;
	if(poolSize != null) this.poolSize = poolSize;
	this.pool = new Array();
};
rx.utils.PooledClass_rx_browser_PutListenerQueue.__name__ = true;
rx.utils.PooledClass_rx_browser_PutListenerQueue.prototype = {
	getPooled: function(arg1) {
		if(this.pool.length > 0) return this.pool.pop(); else return new rx.browser.PutListenerQueue(arg1);
	}
	,release: function(instance) {
		if(Reflect.hasField(instance,"reset")) {
			var func;
			var tmp;
			if(instance == null) func = null; else if(instance.__properties__ && (tmp = instance.__properties__["get_" + "reset"])) func = instance[tmp](); else func = instance.reset;
			func.apply(instance,[]);
		}
		this.pool.push(instance);
	}
	,__class__: rx.utils.PooledClass_rx_browser_PutListenerQueue
};
rx.browser.PutListenerQueue = function(_) {
	this.listenersToPut = new Array();
};
rx.browser.PutListenerQueue.__name__ = true;
rx.browser.PutListenerQueue.prototype = {
	enqueuePutListener: function(rootNodeId,propKey,propValue) {
		this.listenersToPut.push({ rootNodeId : rootNodeId, propKey : propKey, propValue : propValue});
	}
	,putListeners: function() {
		var _g = 0;
		var _g1 = this.listenersToPut;
		while(_g < _g1.length) {
			var listener = _g1[_g];
			++_g;
			rx.browser.EventEmitter.putListener(listener.rootNodeId,listener.propKey,listener.propValue);
		}
	}
	,reset: function() {
		this.listenersToPut.splice(0,this.listenersToPut.length);
	}
	,destructor: function() {
		this.reset();
	}
	,__class__: rx.browser.PutListenerQueue
};
rx.utils.Transaction = function() { };
rx.utils.Transaction.__name__ = true;
rx.utils.Transaction.prototype = {
	getTransactionWrappers: function() {
		return [];
	}
	,reinitializeTransaction: function() {
		this.transactionWrappers = this.getTransactionWrappers();
		this.wrappersInitData = [];
		if(this.timingMetrics == null) this.timingMetrics = { };
		this.timingMetrics.methodInvocationTime = 0;
		this.timingMetrics.wrapperInitTimes = [];
		this.timingMetrics.wrapperCloseTimes = [];
		this._isInTransaction = false;
	}
	,perform: function(method,scope,args) {
		var ret = null;
		this._isInTransaction = true;
		try {
			this.initializeAll(0);
			ret = method.apply(scope,args);
		} catch( e ) {
		}
		this.closeAll(0);
		this._isInTransaction = false;
		return ret;
	}
	,isInTransaction: function() {
		return this._isInTransaction;
	}
	,initializeAll: function(startIndex) {
		var wrappers = this.getTransactionWrappers();
		var _g1 = startIndex;
		var _g = wrappers.length;
		while(_g1 < _g) {
			var i = _g1++;
			var wrapper = wrappers[i];
			wrapper.initialize();
		}
	}
	,closeAll: function(startIndex) {
		var wrappers = this.getTransactionWrappers();
		var _g1 = startIndex;
		var _g = wrappers.length;
		while(_g1 < _g) {
			var i = _g1++;
			var wrapper = wrappers[i];
			wrapper.close();
		}
	}
	,__class__: rx.utils.Transaction
};
rx.utils.PooledClass_rx_browser_ReconcileTransaction = function(poolSize) {
	this.poolSize = 10;
	if(poolSize != null) this.poolSize = poolSize;
	this.pool = new Array();
};
rx.utils.PooledClass_rx_browser_ReconcileTransaction.__name__ = true;
rx.utils.PooledClass_rx_browser_ReconcileTransaction.prototype = {
	getPooled: function(arg1) {
		if(this.pool.length > 0) return this.pool.pop(); else return new rx.browser.ReconcileTransaction(arg1);
	}
	,release: function(instance) {
		if(Reflect.hasField(instance,"reset")) {
			var func;
			var tmp;
			if(instance == null) func = null; else if(instance.__properties__ && (tmp = instance.__properties__["get_" + "reset"])) func = instance[tmp](); else func = instance.reset;
			func.apply(instance,[]);
		}
		this.pool.push(instance);
	}
	,__class__: rx.utils.PooledClass_rx_browser_ReconcileTransaction
};
rx.browser.ReconcileTransaction = function(_) {
	this.reinitializeTransaction();
	this.renderToStaticMarkup = false;
	this.mountReady = rx.core.MountReady.pool.getPooled();
	this.putListenerQueue = rx.browser.PutListenerQueue.pool.getPooled();
};
rx.browser.ReconcileTransaction.__name__ = true;
rx.browser.ReconcileTransaction.__super__ = rx.utils.Transaction;
rx.browser.ReconcileTransaction.prototype = $extend(rx.utils.Transaction.prototype,{
	getTransactionWrappers: function() {
		var _g = this;
		var selectionRestoration = { initialize : function() {
		}, close : function() {
		}};
		var eventSupression = { initialize : function() {
		}, close : function() {
		}};
		var onDomReadyQueueing = { initialize : function() {
			_g.mountReady.reset();
		}, close : function() {
			_g.mountReady.notifyAll();
		}};
		var putListenerQueueing = { initialize : function() {
			_g.putListenerQueue.reset();
		}, close : function() {
			_g.putListenerQueue.putListeners();
		}};
		return [selectionRestoration,eventSupression,onDomReadyQueueing,putListenerQueueing];
	}
	,getMountReady: function() {
		return this.mountReady;
	}
	,getPutListenerQueue: function() {
		return this.putListenerQueue;
	}
	,__class__: rx.browser.ReconcileTransaction
});
rx.browser.RootIndex = function() { };
rx.browser.RootIndex.__name__ = true;
rx.browser.RootIndex.createReactRootIndex = function() {
	return rx.browser.RootIndex._rootIndex++;
};
rx.core.Descriptor = function(children,props) {
	if(children != null) this.children = children; else this.children = new Array();
	if(props != null) this.props = props; else this.props = { };
	this.props.children = children;
};
rx.core.Descriptor.__name__ = true;
rx.core.Descriptor.cloneAndReplaceProps = function(oldDescriptor,newProps) {
	var newDescriptor = new rx.core.Descriptor(oldDescriptor.children,oldDescriptor.props);
	newDescriptor.props = newProps;
	return newDescriptor;
};
rx.core.Descriptor.prototype = {
	__class__: rx.core.Descriptor
};
rx.browser.ui = {};
rx.browser.ui.DOM = function() { };
rx.browser.ui.DOM.__name__ = true;
rx.browser.ui.DOM.el = function(tagName,children,props) {
	var descriptor = new rx.core.Descriptor(children,props);
	return new rx.browser.ui.dom.Component(tagName,rx.browser.ui.DOM.tagsMap[tagName],descriptor);
};
rx.browser.ui.DOM.text = function(text) {
	return new rx.browser.ui.dom.components.Text(text,rx.browser.ui.DOM.emptyDescriptor);
};
rx.browser.ui.Environment = function() { };
rx.browser.ui.Environment.__name__ = true;
rx.browser.ui.Environment.mountImageIntoNode = function(markup,container,shouldReuseMarkup) {
	container.innerHTML = markup;
};
rx.browser.ui.Environment.unmountIdFromEnvironment = function(rootNodeId) {
	rx.browser.ui.Mount.purgeId(rootNodeId);
};
rx.browser.ui.Mount = function() { };
rx.browser.ui.Mount.__name__ = true;
rx.browser.ui.Mount.scrollMonitor = function(container,renderCallback) {
	renderCallback();
};
rx.browser.ui.Mount.getReactRootElementInContainer = function(container) {
	if(container == null) return null;
	if(container.nodeType == 9) return window.document.documentElement; else return container.firstChild;
};
rx.browser.ui.Mount.internalGetId = function(node) {
	var id = "";
	if(Reflect.hasField(node,"getAttribute") != null) {
		var func;
		var tmp;
		if(node == null) func = null; else if(node.__properties__ && (tmp = node.__properties__["get_" + "getAttribute"])) func = node[tmp](); else func = node.getAttribute;
		id = func.apply(node,[rx.browser.ui.Mount.ATTR_NAME]);
	}
	return id;
};
rx.browser.ui.Mount.getId = function(node) {
	var id = rx.browser.ui.Mount.internalGetId(node);
	if(id != null) {
		if(rx.browser.ui.Mount.nodeCache[id] != undefined) {
			var cached = rx.browser.ui.Mount.nodeCache[id];
			if(cached != node) throw "Mount: Two valid but unequal nodes with the same `" + rx.browser.ui.Mount.ATTR_NAME + "`:" + id;
			rx.browser.ui.Mount.nodeCache[id] = node;
		} else rx.browser.ui.Mount.nodeCache[id] = node;
	}
	return id;
};
rx.browser.ui.Mount.purgeId = function(id) {
	Reflect.deleteField(rx.browser.ui.Mount.nodeCache,id);
};
rx.browser.ui.Mount.getNode = function(id) {
	if(!(rx.browser.ui.Mount.nodeCache[id] != undefined) || !rx.browser.ui.Mount.isValid(rx.browser.ui.Mount.nodeCache[id],id)) {
		var value = rx.browser.ui.Mount.findReactNodeForId(id);
		rx.browser.ui.Mount.nodeCache[id] = value;
	}
	return rx.browser.ui.Mount.nodeCache[id];
};
rx.browser.ui.Mount.isValid = function(node,id) {
	if(node != null) {
		if(rx.browser.ui.Mount.internalGetId(node) != id) throw "Mount: unexpected modification of `" + rx.browser.ui.Mount.ATTR_NAME + "`";
		var container = rx.browser.ui.Mount.findReactContainerForId(id);
		if(container != null && rx.browser.ui.dom.Node.containsNode(container,node)) return true;
	}
	return false;
};
rx.browser.ui.Mount.getReactRootId = function(container) {
	var rootElement = rx.browser.ui.Mount.getReactRootElementInContainer(container);
	if(rootElement != null) return rx.browser.ui.Mount.getId(rootElement);
	return null;
};
rx.browser.ui.Mount.findReactNodeForId = function(id) {
	var reactRoot = rx.browser.ui.Mount.findReactContainerForId(id);
	return rx.browser.ui.Mount.findComponentRoot(reactRoot,id);
};
rx.browser.ui.Mount.findComponentRoot = function(ancestorNode,targetId) {
	var firstChildren = rx.browser.ui.Mount.findComponentRootReusableArray;
	var childIndex = 0;
	var deepestAncestor = rx.browser.ui.Mount.findDeepestCachedAncestor(targetId);
	if(deepestAncestor == null) deepestAncestor = ancestorNode;
	firstChildren[0] = deepestAncestor.firstChild;
	firstChildren.splice(1,firstChildren.length);
	while(childIndex < firstChildren.length) {
		var child = firstChildren[childIndex++];
		var targetChild = null;
		while(child != null) {
			var childId = rx.browser.ui.Mount.getId(child);
			if(childId != null) {
				if(targetId == childId) targetChild = child; else if(rx.core.InstanceHandles.isAncestorIdOf(childId,targetId)) {
					firstChildren.splice(0,firstChildren.length);
					childIndex = 0;
					firstChildren.push(child.firstChild);
				}
			} else firstChildren.push(child.firstChild);
			child = child.nextSibling;
		}
		if(targetChild != null) {
			firstChildren.splice(0,firstChildren.length);
			return targetChild;
		}
	}
	firstChildren.splice(0,firstChildren.length);
	throw "findComponentRoot(..., " + targetId + ") Unable to find element.";
};
rx.browser.ui.Mount.findDeepestCachedAncestorImpl = function(ancestorId) {
	var ancestor = rx.browser.ui.Mount.nodeCache[ancestorId];
	if(ancestor != null && rx.browser.ui.Mount.isValid(ancestor,ancestorId)) rx.browser.ui.Mount.deepestNodeSoFar = ancestor; else return;
};
rx.browser.ui.Mount.findDeepestCachedAncestor = function(targetId) {
	rx.browser.ui.Mount.deepestNodeSoFar = null;
	rx.core.InstanceHandles.traverseAncestors(targetId,rx.browser.ui.Mount.findDeepestCachedAncestorImpl);
	var foundNode = rx.browser.ui.Mount.deepestNodeSoFar;
	rx.browser.ui.Mount.deepestNodeSoFar = null;
	return foundNode;
};
rx.browser.ui.Mount.findReactContainerForId = function(id) {
	var reactRootId = rx.core.InstanceHandles.getReactRootIdFromNodeId(id);
	var container = rx.browser.ui.Mount.containersByReactRootId[reactRootId];
	return container;
};
rx.browser.ui.Mount.getInstanceByContainer = function(container) {
	var id = rx.browser.ui.Mount.getReactRootId(container);
	return rx.browser.ui.Mount.instancesByReactRootId[id];
};
rx.browser.ui.Mount.shouldUpdateReactComponent = function(prev,next) {
	if(prev != null && next != null && Type.getClass(prev) == Type.getClass(next) && prev.descriptor.props.key == next.descriptor.props.key && prev.owner == next.owner) return true;
	return false;
};
rx.browser.ui.Mount.updateRootComponent = function(prev,next,container,callback) {
	var nextProps = next.props;
	rx.browser.ui.Mount.scrollMonitor(container,function() {
		prev.replaceProps(nextProps,callback);
	});
	return prev;
};
rx.browser.ui.Mount.unmountComponentAtNode = function(container) {
};
rx.browser.ui.Mount.registerContainer = function(container) {
	var reactRootId = rx.browser.ui.Mount.getReactRootId(container);
	if(reactRootId != null) reactRootId = rx.core.InstanceHandles.getReactRootIdFromNodeId(reactRootId);
	if(reactRootId == null) reactRootId = rx.core.InstanceHandles.createReactRootId();
	rx.browser.ui.Mount.containersByReactRootId[reactRootId] = container;
	return reactRootId;
};
rx.browser.ui.Mount.registerComponent = function(component,container) {
	var reactRootId = rx.browser.ui.Mount.registerContainer(container);
	rx.browser.ui.Mount.instancesByReactRootId[reactRootId] = component;
	return reactRootId;
};
rx.browser.ui.Mount.renderNewRootComponent = function(component,container,shouldReuseMarkup) {
	var reactRootId = rx.browser.ui.Mount.registerComponent(component,container);
	component.mountComponentIntoNode(reactRootId,container,shouldReuseMarkup);
	return component;
};
rx.browser.ui.Mount.isRenderedByReact = function(node) {
	if(node.nodeType != 1) return false;
	var id = rx.browser.ui.Mount.getId(node);
	if(id != null) return id.charAt(0) == "."; else return false;
};
rx.browser.ui.Mount.renderComponent = function(component,container,callback) {
	var prevComponent = rx.browser.ui.Mount.getInstanceByContainer(container);
	if(prevComponent != null) {
		var prevDescriptor = prevComponent.descriptor;
		var nextDescriptor = component.descriptor;
		if(rx.browser.ui.Mount.shouldUpdateReactComponent(prevComponent,component)) return rx.browser.ui.Mount.updateRootComponent(prevComponent,component,container,callback); else rx.browser.ui.Mount.unmountComponentAtNode(container);
	}
	var reactRootElement = rx.browser.ui.Mount.getReactRootElementInContainer(container);
	var containerHasReactMarkup = reactRootElement != null && rx.browser.ui.Mount.isRenderedByReact(reactRootElement);
	var shouldReuseMarkup = containerHasReactMarkup && prevComponent == null;
	var component1 = rx.browser.ui.Mount.renderNewRootComponent(component,container,shouldReuseMarkup);
	return component1;
};
rx.browser.ui.css = {};
rx.browser.ui.css.PropertyOperations = function() { };
rx.browser.ui.css.PropertyOperations.__name__ = true;
rx.browser.ui.css.PropertyOperations.setValuesForStyles = function(node,styles) {
	console.log("setValuesForStyles");
};
rx.browser.ui.dom = {};
rx.browser.ui.dom.ChildrenOperations = function() { };
rx.browser.ui.dom.ChildrenOperations.__name__ = true;
rx.browser.ui.dom.ChildrenOperations.insertChildAt = function(parentNode,childNode,index) {
	var childNodes = parentNode.childNodes;
	if(childNodes[index] == childNode) return;
	if(childNode.parentNode == parentNode) parentNode.removeChild(childNode);
	if(index >= childNodes.length) parentNode.appendChild(childNode); else parentNode.insertBefore(childNode,childNodes[index]);
};
rx.browser.ui.dom.ChildrenOperations.updateTextContent = function(node,text) {
	node.textContent = text;
};
rx.browser.ui.dom.ChildrenOperations.processUpdates = function(updates,markupList) {
	var initialChildren = null;
	var updatedChildren = null;
	var _g = 0;
	while(_g < updates.length) {
		var update = updates[_g];
		++_g;
		if(update.type == rx.core.UpdateTypes.MoveExisting || update.type == rx.core.UpdateTypes.RemoveNode) {
			var updatedIndex = update.fromIndex;
			var updatedChild = update.parentNode.childNodes[updatedIndex];
			var parentId = update.parentId;
			if(initialChildren == null) initialChildren = { };
			if(updatedChildren == null) updatedChildren = new Array();
			updatedChildren.push(updatedChild);
			if(!(initialChildren[parentId] != undefined) || initialChildren[parentId] == null) {
				var value = new Array();
				initialChildren[parentId] = value;
			}
			var arr = initialChildren[parentId];
			arr[updatedIndex] = updatedChild;
			updatedChildren.push(updatedChild);
		}
	}
	var renderedMarkup = rx.browser.ui.dom.Danger.dangerouslyRenderMarkup(markupList);
	if(updatedChildren != null && updatedChildren.length > 0) {
		var _g = 0;
		while(_g < updatedChildren.length) {
			var child = updatedChildren[_g];
			++_g;
			child.parentNode.removeChild(child);
		}
	}
	var _g = 0;
	try {
		while(_g < updates.length) {
			var update = updates[_g];
			++_g;
			var _g1 = update.type;
			switch((function($this) {
				var $r;
				var e = _g1;
				$r = e[1];
				return $r;
			}(this))) {
			case 0:
				rx.browser.ui.dom.ChildrenOperations.insertChildAt(update.parentNode,renderedMarkup[update.markupIndex],update.toIndex);
				throw "__break__";
				break;
			case 1:
				rx.browser.ui.dom.ChildrenOperations.insertChildAt(update.parentNode,((function($this) {
					var $r;
					var name = update.parentId;
					$r = initialChildren[name];
					return $r;
				}(this)))[update.fromIndex],update.toIndex);
				throw "__break__";
				break;
			case 3:
				rx.browser.ui.dom.ChildrenOperations.updateTextContent(update.parentNode,update.textContent);
				throw "__break__";
				break;
			case 2:
				throw "__break__";
				break;
			}
		}
	} catch( e ) { if( e != "__break__" ) throw e; }
};
rx.core.ContainerComponent = function(descriptor) {
	rx.core.Component.call(this,descriptor);
};
rx.core.ContainerComponent.__name__ = true;
rx.core.ContainerComponent.processQueue = function() {
	if(rx.core.ContainerComponent.updateQueue.length > 0) {
		var updates = rx.core.ContainerComponent.updateQueue;
		var _g = 0;
		while(_g < updates.length) {
			var update = updates[_g];
			++_g;
			update.parentNode = rx.browser.ui.Mount.getNode(update.parentId);
		}
		rx.browser.ui.dom.ChildrenOperations.processUpdates(updates,rx.core.ContainerComponent.markupQueue);
		rx.core.ContainerComponent.clearQueue();
	}
};
rx.core.ContainerComponent.clearQueue = function() {
	rx.core.ContainerComponent.updateQueue.splice(0,rx.core.ContainerComponent.updateQueue.length);
	rx.core.ContainerComponent.markupQueue.splice(0,rx.core.ContainerComponent.markupQueue.length);
};
rx.core.ContainerComponent.__super__ = rx.core.Component;
rx.core.ContainerComponent.prototype = $extend(rx.core.Component.prototype,{
	mountChildren: function(nestedChildren,transaction) {
		var children = rx.utils.FlattenChildren.flattenChildren(nestedChildren);
		var mountImages = [];
		var index = 0;
		this.renderedChildren = children;
		var _g = 0;
		var _g1 = Reflect.fields(children);
		while(_g < _g1.length) {
			var key = _g1[_g];
			++_g;
			var child = children[key];
			var rootId = this.rootNodeId + key;
			var mountImage = child.mountComponent(rootId,transaction,this.mountDepth + 1);
			mountImages.push(mountImage);
			child.mountIndex = index;
			index++;
		}
		return mountImages;
	}
	,updateTextContent: function(content) {
		rx.core.ContainerComponent.updateDepth++;
		console.log("ContainerComponent.updateTextContent");
	}
	,updateChildren: function(nextNestedChildren,transaction) {
		rx.core.ContainerComponent.updateDepth++;
		var errorThrown = true;
		try {
			this._updateChildren(nextNestedChildren,transaction);
			errorThrown = false;
		} catch( e ) {
			if( js.Boot.__instanceof(e,Error) ) {
				console.log(e.stack);
			} else throw(e);
		}
		rx.core.ContainerComponent.updateDepth--;
		if(rx.core.ContainerComponent.updateDepth == 0) {
			if(errorThrown) rx.core.ContainerComponent.clearQueue(); else rx.core.ContainerComponent.processQueue();
		}
	}
	,_updateChildren: function(nextNestedChildren,transaction) {
		var nextChildren = rx.utils.FlattenChildren.flattenChildren(nextNestedChildren);
		var prevChildren = this.renderedChildren;
		if(nextChildren == null && this.renderedChildren == null) return;
		var lastIndex = 0;
		var nextIndex = 0;
		var _g = 0;
		var _g1 = Reflect.fields(nextChildren);
		while(_g < _g1.length) {
			var name = _g1[_g];
			++_g;
			var prevChild = null;
			if(prevChildren != null) prevChild = prevChildren[name];
			var nextChild = nextChildren[name];
			if(rx.core.Component.shouldUpdate(prevChild,nextChild)) {
				this.moveChild(prevChild,nextIndex,lastIndex);
				var x = Math.max(prevChild.mountIndex,lastIndex);
				lastIndex = x | 0;
				prevChild.receiveComponent(nextChild,transaction);
				prevChild.mountIndex = nextIndex;
			} else {
				if(prevChild != null) {
					var x = Math.max(prevChild.mountIndex,lastIndex);
					lastIndex = x | 0;
					this.unmountChildByName(prevChild,name);
				}
				this.mountChildByNameAtIndex(nextChild,name,nextIndex,transaction);
			}
			nextIndex++;
		}
		var _g = 0;
		var _g1 = Reflect.fields(prevChildren);
		while(_g < _g1.length) {
			var name = _g1[_g];
			++_g;
			var prevChild = prevChildren[name];
			if(prevChild != null && nextChildren != null && !(nextChildren[name] != undefined)) this.unmountChildByName(prevChildren[name],name);
		}
	}
	,enqueueMarkup: function(parentId,markup,toIndex) {
		rx.core.ContainerComponent.updateQueue.push({ parentId : parentId, parentNode : null, type : rx.core.UpdateTypes.InsertMarkup, markupIndex : rx.core.ContainerComponent.markupQueue.push(markup) - 1, textContent : null, fromIndex : null, toIndex : toIndex});
	}
	,unmountChildren: function() {
		console.log("ContainerComponent.unmountChildren");
	}
	,moveChild: function(child,toIndex,lastIndex) {
	}
	,createChild: function(child,mountImage) {
		this.enqueueMarkup(this.rootNodeId,mountImage,child.mountIndex);
	}
	,removeChild: function(child) {
		console.log("ContainerComponent.removeChild");
	}
	,setTextContent: function(content) {
		console.log("ContainerComponent.setTextContent");
	}
	,mountChildByNameAtIndex: function(child,name,index,transaction) {
		var rootId = this.rootNodeId + name;
		var mountImage = child.mountComponent(rootId,transaction,this.mountDepth + 1);
		child.mountIndex = index;
		this.createChild(child,mountImage);
		if(this.renderedChildren == null) this.renderedChildren = { };
		this.renderedChildren[name] = child;
	}
	,unmountChildByName: function(child,name) {
		console.log("unmountChildByName(..., " + name + ")");
	}
	,__class__: rx.core.ContainerComponent
});
rx.browser.ui.dom.Component = function(tagName,omitClose,descriptor) {
	rx.core.ContainerComponent.call(this,descriptor);
	this.tagOpen = "<" + tagName;
	if(omitClose) this.tagClose = ""; else this.tagClose = "</" + tagName + ">";
};
rx.browser.ui.dom.Component.__name__ = true;
rx.browser.ui.dom.Component.__super__ = rx.core.ContainerComponent;
rx.browser.ui.dom.Component.prototype = $extend(rx.core.ContainerComponent.prototype,{
	mountComponent: function(rootId,transaction,mountDepth) {
		rx.core.ContainerComponent.prototype.mountComponent.call(this,rootId,transaction,mountDepth);
		return this.createOpenTagMarkupAndPutListeners(transaction) + this.createContentMarkup(transaction) + this.tagClose;
	}
	,putListener: function(id,registrationName,listener,transaction) {
		var container = rx.browser.ui.Mount.findReactContainerForId(id);
		if(container != null) {
			var doc;
			if(container.nodeType == rx.browser.ui.dom.Component.ELEMENT_NODE_TYPE) doc = container.ownerDocument; else doc = container;
			console.log("listenTo: registrationName");
		}
		transaction.getPutListenerQueue().enqueuePutListener(id,registrationName,listener);
	}
	,createOpenTagMarkupAndPutListeners: function(transaction) {
		var props = this.props;
		var ret = this.tagOpen;
		if(props != null) {
			var _g = 0;
			var _g1 = Reflect.fields(props);
			while(_g < _g1.length) {
				var propKey = _g1[_g];
				++_g;
				var propValue = props[propKey];
				if(propValue == null) continue;
				if(rx.browser.EventEmitter.registrationNameModules[propKey] != undefined) this.putListener(this.rootNodeId,propKey,propValue,transaction); else {
					var markup = rx.browser.ui.dom.PropertyOperations.createMarkupForProperty(propKey,propValue);
					if(markup != "" && markup != null) ret += " " + markup;
				}
			}
		}
		if(transaction.renderToStaticMarkup) return ret + ">";
		var markupForId = rx.browser.ui.dom.PropertyOperations.createMarkupForId(this.rootNodeId);
		return ret + " " + markupForId + ">";
	}
	,createContentMarkup: function(transaction) {
		var children = this.props.children;
		var mountImages = this.mountChildren(children,transaction);
		return mountImages.join("");
	}
	,updateComponent: function(transaction,props,owner,prevProps,prevOwner,prevChildren) {
		rx.core.ContainerComponent.prototype.updateComponent.call(this,transaction,props,owner);
		this._updateDOMProperties(props,transaction);
		this._updateDOMChildren(props,transaction);
	}
	,_updateDOMProperties: function(lastProps,transaction) {
		var nextProps = this.props;
		var styleName = null;
		var styleUpdates = null;
		if(lastProps == null) return;
		var _g = 0;
		var _g1 = Reflect.fields(lastProps);
		while(_g < _g1.length) {
			var propKey = _g1[_g];
			++_g;
			if(nextProps[propKey] != undefined) continue;
			if(propKey == "azaza") {
			} else if(rx.browser.EventEmitter.registrationNameModules[propKey]) {
			} else if(rx.browser.ui.dom.Property.isStandardName(propKey) || rx.browser.ui.dom.Property.isCustomAttribute(propKey)) {
				var node = rx.browser.ui.Mount.getNode(this.rootNodeId);
				rx.browser.ui.dom.PropertyOperations.deleteValueForProperty(node,propKey);
			}
		}
		var _g = 0;
		var _g1 = Reflect.fields(nextProps);
		while(_g < _g1.length) {
			var propKey = _g1[_g];
			++_g;
			var nextProp = nextProps[propKey];
			var lastProp = lastProps[propKey];
			if(nextProp == lastProp) continue;
			if(propKey == "style") {
			} else if(rx.browser.EventEmitter.registrationNameModules[propKey]) {
			} else if(rx.browser.ui.dom.Property.isStandardName(propKey) || rx.browser.ui.dom.Property.isCustomAttribute(propKey)) {
				var node = rx.browser.ui.Mount.getNode(this.rootNodeId);
				if(nextProp != null) {
					var node1 = node;
					if(rx.browser.ui.dom.Property.isStandardName(propKey)) {
						var mutationMethod = rx.browser.ui.dom.Property.getMutationMethod(propKey);
						if(mutationMethod != null) mutationMethod(node1,nextProp); else if(rx.browser.ui.dom.PropertyOperations.shouldIgnoreValue(propKey,nextProp)) rx.browser.ui.dom.PropertyOperations.deleteValueForProperty(node1,propKey); else if(rx.browser.ui.dom.Property.mustUseAttributeName(propKey)) node1.setAttribute(rx.browser.ui.dom.Property.getAttributeName(propKey),nextProp); else {
							var propName = rx.browser.ui.dom.Property.getPropertyName(propKey);
							if(rx.browser.ui.dom.Property.hasSideEffects(propKey) || (function($this) {
								var $r;
								var v = null;
								try {
									v = node1[propName];
								} catch( e ) {
								}
								$r = v;
								return $r;
							}(this)) != nextProp) node1[propName] = nextProp;
						}
					} else if(rx.browser.ui.dom.Property.isCustomAttribute(propKey)) {
						if(nextProp == null) node1.removeAttribute(rx.browser.ui.dom.Property.getAttributeName(propKey)); else node1.setAttribute(propKey,nextProp);
					}
				} else rx.browser.ui.dom.PropertyOperations.deleteValueForProperty(node,propKey);
			}
		}
	}
	,_updateDOMChildren: function(lastProps,transaction) {
		var nextProps = this.props;
		var lastChildren = lastProps.children;
		var nextChildren = nextProps.children;
		if(lastChildren != null && nextChildren == null) this.updateChildren(null,transaction); else if(nextChildren != null) this.updateChildren(nextChildren,transaction);
	}
	,__class__: rx.browser.ui.dom.Component
});
rx.browser.ui.dom.Danger = function() { };
rx.browser.ui.dom.Danger.__name__ = true;
rx.browser.ui.dom.Danger.createArrayFrom = function(obj) {
	var res = [];
	var _g = 0;
	while(_g < obj.length) {
		var i = obj[_g];
		++_g;
		res.push(i);
	}
	return res;
};
rx.browser.ui.dom.Danger.createNodesFromMarkup = function(markup,handleScript) {
	var node = rx.browser.ui.dom.Danger.dummyNode;
	var nodeName = rx.browser.ui.dom.Danger.getNodeName(markup);
	var wrap = null;
	if(nodeName != null) wrap = rx.browser.ui.dom.Danger.getMarkupWrap(nodeName);
	if(wrap != null) {
		node.innerHTML = wrap[1] + markup + wrap[2];
		var wrapDepth = wrap[0];
		while(wrapDepth-- > 0) node = node.lastChild;
	} else node.innerHTML = markup;
	var nodes = rx.browser.ui.dom.Danger.createArrayFrom(node.childNodes);
	while(node.lastChild != null) node.removeChild(node.lastChild);
	return nodes;
};
rx.browser.ui.dom.Danger.getNodeName = function(markup) {
	return markup.substring(1,markup.indexOf(" "));
};
rx.browser.ui.dom.Danger.getMarkupWrap = function(name) {
	return null;
};
rx.browser.ui.dom.Danger.dangerouslyRenderMarkup = function(markupList) {
	var nodeName = null;
	var markupByNodeName = { };
	var _g1 = 0;
	var _g = markupList.length;
	while(_g1 < _g) {
		var i = _g1++;
		nodeName = rx.browser.ui.dom.Danger.getNodeName(markupList[i]);
		if(rx.browser.ui.dom.Danger.getMarkupWrap(nodeName) != null) nodeName = nodeName; else nodeName = "*";
		if(!(markupByNodeName[nodeName] != undefined)) markupByNodeName[nodeName] = [];
		markupByNodeName[nodeName][i] = markupList[i];
	}
	var resultList = [];
	var resultListAssignmentCount = 0;
	var _g = 0;
	var _g1 = Reflect.fields(markupByNodeName);
	while(_g < _g1.length) {
		var nodeName1 = _g1[_g];
		++_g;
		var markupListByNodeName = markupByNodeName[nodeName1];
		var _g3 = 0;
		var _g2 = markupListByNodeName.length;
		while(_g3 < _g2) {
			var resultIndex = _g3++;
			var markup = markupListByNodeName[resultIndex];
			markupListByNodeName[resultIndex] = rx.browser.ui.dom.Danger.OPEN_TAG_NAME_EXP.replace(markup,"$1 " + rx.browser.ui.dom.Danger.RESULT_INDEX_ATTR + "=\"" + resultIndex + "\" ");
		}
		var renderNodes = rx.browser.ui.dom.Danger.createNodesFromMarkup(markupListByNodeName.join(""),function() {
		});
		var _g3 = 0;
		var _g2 = renderNodes.length;
		while(_g3 < _g2) {
			var i = _g3++;
			var renderNode = renderNodes[i];
			if($bind(renderNode,renderNode.hasAttribute) != null && renderNode.hasAttribute(rx.browser.ui.dom.Danger.RESULT_INDEX_ATTR)) {
				var resultIndex = Std.parseInt(renderNode.getAttribute(rx.browser.ui.dom.Danger.RESULT_INDEX_ATTR));
				renderNode.removeAttribute(rx.browser.ui.dom.Danger.RESULT_INDEX_ATTR);
				resultList[resultIndex] = renderNode;
				resultListAssignmentCount += 1;
			}
		}
	}
	return resultList;
};
rx.browser.ui.dom.Danger.dangerouslyReplaceNodeWithMarkup = function(oldChild,markup) {
	var newChild = rx.browser.ui.dom.Danger.createNodesFromMarkup(markup,function() {
	})[0];
	oldChild.parentNode.replaceChild(newChild,oldChild);
};
rx.browser.ui.dom.IdOperations = function() { };
rx.browser.ui.dom.IdOperations.__name__ = true;
rx.browser.ui.dom.IdOperations.updatePropertyById = function(id,name,value) {
	var node = rx.browser.ui.Mount.getNode(id);
	if(value != null) {
		var node1 = node;
		if(rx.browser.ui.dom.Property.isStandardName(name)) {
			var mutationMethod = rx.browser.ui.dom.Property.getMutationMethod(name);
			if(mutationMethod != null) mutationMethod(node1,value); else if(rx.browser.ui.dom.PropertyOperations.shouldIgnoreValue(name,value)) rx.browser.ui.dom.PropertyOperations.deleteValueForProperty(node1,name); else if(rx.browser.ui.dom.Property.mustUseAttributeName(name)) node1.setAttribute(rx.browser.ui.dom.Property.getAttributeName(name),value); else {
				var propName = rx.browser.ui.dom.Property.getPropertyName(name);
				if(rx.browser.ui.dom.Property.hasSideEffects(name) || (function($this) {
					var $r;
					var v = null;
					try {
						v = node1[propName];
					} catch( e ) {
					}
					$r = v;
					return $r;
				}(this)) != value) node1[propName] = value;
			}
		} else if(rx.browser.ui.dom.Property.isCustomAttribute(name)) {
			if(value == null) node1.removeAttribute(rx.browser.ui.dom.Property.getAttributeName(name)); else node1.setAttribute(name,value);
		}
	} else rx.browser.ui.dom.PropertyOperations.deleteValueForProperty(node,name);
};
rx.browser.ui.dom.IdOperations.deletePropertyById = function(id,name) {
	var node = rx.browser.ui.Mount.getNode(id);
	rx.browser.ui.dom.PropertyOperations.deleteValueForProperty(node,name);
};
rx.browser.ui.dom.IdOperations.updateStylesById = function(id,styles) {
	var node = rx.browser.ui.Mount.getNode(id);
	rx.browser.ui.css.PropertyOperations.setValuesForStyles(node,styles);
};
rx.browser.ui.dom.IdOperations.updateInnerHTMLById = function(id,html) {
	var node = rx.browser.ui.Mount.getNode(id);
	node.innerHTML = html;
};
rx.browser.ui.dom.IdOperations.updateTextContentById = function(id,content) {
	var node = rx.browser.ui.Mount.getNode(id);
	rx.browser.ui.dom.ChildrenOperations.updateTextContent(node,content);
};
rx.browser.ui.dom.IdOperations.dangerouslyReplaceNodeWithMarkupById = function(id,markup) {
	var node = rx.browser.ui.Mount.getNode(id);
	rx.browser.ui.dom.Danger.dangerouslyReplaceNodeWithMarkup(node,markup);
};
rx.browser.ui.dom.IdOperations.dangerouslyProcessChildrenUpdates = function(updates,markup) {
	var _g = 0;
	while(_g < updates.length) {
		var update = updates[_g];
		++_g;
		update.parentNode = rx.browser.ui.Mount.getNode(update.parentId);
	}
	rx.browser.ui.dom.ChildrenOperations.processUpdates(updates,markup);
};
rx.browser.ui.dom.Node = function() { };
rx.browser.ui.dom.Node.__name__ = true;
rx.browser.ui.dom.Node.containsNode = function(outerNode,innerNode) {
	if(outerNode == null || innerNode == null) return false; else if(outerNode == innerNode) return true; else if(rx.browser.ui.dom.Node.isTextNode(outerNode)) return false; else if(rx.browser.ui.dom.Node.isTextNode(innerNode)) return rx.browser.ui.dom.Node.containsNode(outerNode,innerNode.parentNode); else if($bind(outerNode,outerNode.contains) != null) return outerNode.contains(innerNode); else if($bind(outerNode,outerNode.compareDocumentPosition) != null) return (outerNode.compareDocumentPosition(innerNode) & 16) != 0; else return false;
};
rx.browser.ui.dom.Node.isTextNode = function(node) {
	return node.nodeType == 3;
};
rx.browser.ui.dom.Check = function() { };
rx.browser.ui.dom.Check.__name__ = true;
rx.browser.ui.dom.Property = function() { };
rx.browser.ui.dom.Property.__name__ = true;
rx.browser.ui.dom.Property.isStandardName = function(name) {
	return (function($this) {
		var $r;
		var v = null;
		try {
			v = rx.browser.ui.dom.Check.Properties[name];
		} catch( e ) {
		}
		$r = v;
		return $r;
	}(this)) != null;
};
rx.browser.ui.dom.Property.getMutationMethod = function(name) {
	return null;
};
rx.browser.ui.dom.Property.mustUseAttributeName = function(name) {
	return (function($this) {
		var $r;
		var v = null;
		try {
			v = rx.browser.ui.dom.Check.Properties[name];
		} catch( e ) {
		}
		$r = v;
		return $r;
	}(this)) & 1;
};
rx.browser.ui.dom.Property.getAttributeName = function(name) {
	var v = null;
	try {
		v = rx.browser.ui.dom.Check.DOMAttributeNames[name];
	} catch( e ) {
	}
	return v;
};
rx.browser.ui.dom.Property.getPropertyName = function(name) {
	var v = null;
	try {
		v = rx.browser.ui.dom.Check.DOMPropertyNames[name];
	} catch( e ) {
	}
	return v;
};
rx.browser.ui.dom.Property.hasSideEffects = function(name) {
	return (function($this) {
		var $r;
		var v = null;
		try {
			v = rx.browser.ui.dom.Check.Properties[name];
		} catch( e ) {
		}
		$r = v;
		return $r;
	}(this)) & 8;
};
rx.browser.ui.dom.Property.isCustomAttribute = function(name) {
	return name.indexOf("data-") == 0 || name.indexOf("area-") == 0;
};
rx.browser.ui.dom.Property.hasBooleanValue = function(name) {
	return (function($this) {
		var $r;
		var v = null;
		try {
			v = 1[name];
		} catch( e ) {
		}
		$r = v;
		return $r;
	}(this)) & 4;
};
rx.browser.ui.dom.Property.hasPositiveNumbericValue = function(name) {
	return (function($this) {
		var $r;
		var v = null;
		try {
			v = 1[name];
		} catch( e ) {
		}
		$r = v;
		return $r;
	}(this)) & 16;
};
rx.browser.ui.dom.Property.getDefaultValueForProperty = function(nodeName,prop) {
	var nodeDefaults = rx.browser.ui.dom.Property.defaultValueCache[nodeName];
	var testElement;
	if(nodeDefaults == null) {
		nodeDefaults = { };
		rx.browser.ui.dom.Property.defaultValueCache[nodeName] = nodeDefaults;
	}
	if(!(nodeDefaults[prop] != undefined)) {
		testElement = window.document.createElement(nodeName);
		var value;
		var v = null;
		try {
			v = testElement[prop];
		} catch( e ) {
		}
		value = v;
		nodeDefaults[prop] = value;
	}
	return nodeDefaults[prop];
};
rx.browser.ui.dom.PropertyOperations = function() { };
rx.browser.ui.dom.PropertyOperations.__name__ = true;
rx.browser.ui.dom.PropertyOperations.escapeTextForBrowser = function(text) {
	return text;
};
rx.browser.ui.dom.PropertyOperations.processAttributeNameAndPrefix = function(name) {
	return rx.browser.ui.dom.PropertyOperations.escapeTextForBrowser(name) + "=\"";
};
rx.browser.ui.dom.PropertyOperations.createMarkupForId = function(id) {
	return rx.browser.ui.dom.PropertyOperations.processAttributeNameAndPrefix("data-reactid") + rx.browser.ui.dom.PropertyOperations.escapeTextForBrowser(id) + "\"";
};
rx.browser.ui.dom.PropertyOperations.createMarkupForProperty = function(name,value) {
	if(rx.browser.ui.dom.Property.isStandardName(name)) {
		if(rx.browser.ui.dom.PropertyOperations.shouldIgnoreValue(name,value)) return "";
		var attributeName = rx.browser.ui.dom.Property.getAttributeName(name);
		if(rx.browser.ui.dom.Property.hasBooleanValue(name)) return rx.browser.ui.dom.PropertyOperations.escapeTextForBrowser(attributeName);
		return rx.browser.ui.dom.PropertyOperations.processAttributeNameAndPrefix(attributeName) + rx.browser.ui.dom.PropertyOperations.escapeTextForBrowser(value) + "\"";
	} else if(rx.browser.ui.dom.Property.isCustomAttribute(name)) {
		if(value == null) return "";
		return rx.browser.ui.dom.PropertyOperations.processAttributeNameAndPrefix(name) + rx.browser.ui.dom.PropertyOperations.escapeTextForBrowser(value) + "\"";
	} else {
	}
	return null;
};
rx.browser.ui.dom.PropertyOperations.shouldIgnoreValue = function(name,value) {
	return value == null || rx.browser.ui.dom.Property.hasBooleanValue(name) && !value || rx.browser.ui.dom.Property.hasPositiveNumbericValue(name) && (Math.isNaN(value) || value < 1);
};
rx.browser.ui.dom.PropertyOperations.setValueForProperty = function(node,name,value) {
	if(rx.browser.ui.dom.Property.isStandardName(name)) {
		var mutationMethod = rx.browser.ui.dom.Property.getMutationMethod(name);
		if(mutationMethod != null) mutationMethod(node,value); else if(rx.browser.ui.dom.PropertyOperations.shouldIgnoreValue(name,value)) rx.browser.ui.dom.PropertyOperations.deleteValueForProperty(node,name); else if(rx.browser.ui.dom.Property.mustUseAttributeName(name)) node.setAttribute(rx.browser.ui.dom.Property.getAttributeName(name),value); else {
			var propName = rx.browser.ui.dom.Property.getPropertyName(name);
			if(rx.browser.ui.dom.Property.hasSideEffects(name) || (function($this) {
				var $r;
				var v = null;
				try {
					v = node[propName];
				} catch( e ) {
				}
				$r = v;
				return $r;
			}(this)) != value) node[propName] = value;
		}
	} else if(rx.browser.ui.dom.Property.isCustomAttribute(name)) {
		if(value == null) node.removeAttribute(rx.browser.ui.dom.Property.getAttributeName(name)); else node.setAttribute(name,value);
	}
};
rx.browser.ui.dom.PropertyOperations.deleteValueForProperty = function(node,name) {
	if(rx.browser.ui.dom.Property.isStandardName(name)) {
		if(rx.browser.ui.dom.Property.mustUseAttributeName(name)) node.removeAttribute(rx.browser.ui.dom.Property.getAttributeName(name)); else {
			var propName = rx.browser.ui.dom.Property.getAttributeName(name);
			var defaultValue = rx.browser.ui.dom.Property.getDefaultValueForProperty(node.nodeName,name);
			if(!rx.browser.ui.dom.Property.hasSideEffects(name) || (function($this) {
				var $r;
				var v = null;
				try {
					v = node[propName];
				} catch( e ) {
				}
				$r = v;
				return $r;
			}(this)) != defaultValue) node[propName] = defaultValue;
		}
	} else if(rx.browser.ui.dom.Property.isCustomAttribute(name)) node.removeAttribute(name);
};
rx.browser.ui.dom.components = {};
rx.browser.ui.dom.components.Text = function(text,descriptor) {
	rx.core.Component.call(this,descriptor);
	this.text = text;
};
rx.browser.ui.dom.components.Text.__name__ = true;
rx.browser.ui.dom.components.Text.__super__ = rx.core.Component;
rx.browser.ui.dom.components.Text.prototype = $extend(rx.core.Component.prototype,{
	mountComponent: function(rootId,transaction,mountDepth) {
		rx.core.Component.prototype.mountComponent.call(this,rootId,transaction,mountDepth);
		var id = rx.browser.ui.dom.PropertyOperations.createMarkupForId(rootId);
		return "<span " + id + ">" + this.text + "</span>";
	}
	,receiveComponent: function(nextComponent,transaction) {
		var next = nextComponent;
		var nextText = next.text;
		if(nextText != this.text) {
			this.text = nextText;
			var node = rx.browser.ui.Mount.getNode(this.rootNodeId);
			rx.browser.ui.dom.ChildrenOperations.updateTextContent(node,nextText);
		}
	}
	,__class__: rx.browser.ui.dom.components.Text
});
rx.core.BatchingTransaction = function() {
	this.reinitializeTransaction();
};
rx.core.BatchingTransaction.__name__ = true;
rx.core.BatchingTransaction.__super__ = rx.utils.Transaction;
rx.core.BatchingTransaction.prototype = $extend(rx.utils.Transaction.prototype,{
	getTransactionWrappers: function() {
		var resetBatchUpdatesWrapper = { initialize : function() {
		}, close : function() {
			rx.core.BatchingStrategy.isBatchingUpdates = false;
		}};
		var flushBatchedUpdatesWrapper = { initialize : function() {
		}, close : function() {
			rx.core.Updates.flushBatchedUpdates();
		}};
		return [resetBatchUpdatesWrapper,flushBatchedUpdatesWrapper];
	}
	,__class__: rx.core.BatchingTransaction
});
rx.core.BatchingStrategy = function() { };
rx.core.BatchingStrategy.__name__ = true;
rx.core.BatchingStrategy.batchUpdates = function(callback,param) {
	var alreadyBathingUpdates = rx.core.BatchingStrategy.isBatchingUpdates;
	rx.core.BatchingStrategy.isBatchingUpdates = true;
	if(alreadyBathingUpdates) callback(param); else rx.core.BatchingStrategy.transaction.perform(callback,null,[param]);
};
rx.core.Lifecycle = { __ename__ : true, __constructs__ : ["Mounted","Unmounted"] };
rx.core.Lifecycle.Mounted = ["Mounted",0];
rx.core.Lifecycle.Mounted.toString = $estr;
rx.core.Lifecycle.Mounted.__enum__ = rx.core.Lifecycle;
rx.core.Lifecycle.Unmounted = ["Unmounted",1];
rx.core.Lifecycle.Unmounted.toString = $estr;
rx.core.Lifecycle.Unmounted.__enum__ = rx.core.Lifecycle;
rx.core.CompositeLifecycle = { __ename__ : true, __constructs__ : ["Mounting","Unmounting","ReceivingProps","ReceivingState"] };
rx.core.CompositeLifecycle.Mounting = ["Mounting",0];
rx.core.CompositeLifecycle.Mounting.toString = $estr;
rx.core.CompositeLifecycle.Mounting.__enum__ = rx.core.CompositeLifecycle;
rx.core.CompositeLifecycle.Unmounting = ["Unmounting",1];
rx.core.CompositeLifecycle.Unmounting.toString = $estr;
rx.core.CompositeLifecycle.Unmounting.__enum__ = rx.core.CompositeLifecycle;
rx.core.CompositeLifecycle.ReceivingProps = ["ReceivingProps",2];
rx.core.CompositeLifecycle.ReceivingProps.toString = $estr;
rx.core.CompositeLifecycle.ReceivingProps.__enum__ = rx.core.CompositeLifecycle;
rx.core.CompositeLifecycle.ReceivingState = ["ReceivingState",3];
rx.core.CompositeLifecycle.ReceivingState.toString = $estr;
rx.core.CompositeLifecycle.ReceivingState.__enum__ = rx.core.CompositeLifecycle;
rx.core.UpdateTypes = { __ename__ : true, __constructs__ : ["InsertMarkup","MoveExisting","RemoveNode","TextContent"] };
rx.core.UpdateTypes.InsertMarkup = ["InsertMarkup",0];
rx.core.UpdateTypes.InsertMarkup.toString = $estr;
rx.core.UpdateTypes.InsertMarkup.__enum__ = rx.core.UpdateTypes;
rx.core.UpdateTypes.MoveExisting = ["MoveExisting",1];
rx.core.UpdateTypes.MoveExisting.toString = $estr;
rx.core.UpdateTypes.MoveExisting.__enum__ = rx.core.UpdateTypes;
rx.core.UpdateTypes.RemoveNode = ["RemoveNode",2];
rx.core.UpdateTypes.RemoveNode.toString = $estr;
rx.core.UpdateTypes.RemoveNode.__enum__ = rx.core.UpdateTypes;
rx.core.UpdateTypes.TextContent = ["TextContent",3];
rx.core.UpdateTypes.TextContent.toString = $estr;
rx.core.UpdateTypes.TextContent.__enum__ = rx.core.UpdateTypes;
rx.core.Context = function() { };
rx.core.Context.__name__ = true;
rx.core.Context.withContext = function(newContext,scopedCallback) {
	return newContext;
};
rx.core.InstanceHandles = function() { };
rx.core.InstanceHandles.__name__ = true;
rx.core.InstanceHandles.getReactRootIdString = function(index) {
	return rx.core.InstanceHandles.SEPARATOR + index.toString(36);
};
rx.core.InstanceHandles.createReactRootId = function() {
	return rx.core.InstanceHandles.getReactRootIdString(rx.browser.RootIndex.createReactRootIndex());
};
rx.core.InstanceHandles.createReactID = function(rootId,name) {
	return rootId + name;
};
rx.core.InstanceHandles.getReactRootIdFromNodeId = function(id) {
	if(id != null && id.charAt(0) == rx.core.InstanceHandles.SEPARATOR && id.length > 1) {
		var index = id.indexOf(rx.core.InstanceHandles.SEPARATOR,1);
		if(index > -1) return HxOverrides.substr(id,0,index); else return id;
	}
	return null;
};
rx.core.InstanceHandles.getParentId = function(id,_) {
	if(id != null) return id.substring(0,id.lastIndexOf(rx.core.InstanceHandles.SEPARATOR)); else return "";
};
rx.core.InstanceHandles.isValidId = function(id) {
	return id == "" || id.charAt(0) == rx.core.InstanceHandles.SEPARATOR && id.charAt(id.length - 1) != rx.core.InstanceHandles.SEPARATOR;
};
rx.core.InstanceHandles.getNextDescendantId = function(ancestorId,destinationId) {
	if(!rx.core.InstanceHandles.isValidId(ancestorId) || !rx.core.InstanceHandles.isValidId(destinationId)) throw "getNextDescendantId(" + ancestorId + ", " + destinationId + "): Received an invalid DOM ID.";
	if(!rx.core.InstanceHandles.isAncestorIdOf(ancestorId,destinationId)) throw "getNextDescendantId(" + ancestorId + ", " + destinationId + "): React has made an invalid assumption about the DOM hierarchy..";
	if(ancestorId == destinationId) return ancestorId;
	var start = ancestorId.length + rx.core.InstanceHandles.SEPARATOR.length;
	var _i = null;
	var _g1 = start;
	var _g = destinationId.length;
	while(_g1 < _g) {
		var i = _g1++;
		if(rx.core.InstanceHandles.isBoundary(destinationId,i)) {
			_i = i;
			break;
		}
	}
	return HxOverrides.substr(destinationId,0,_i);
};
rx.core.InstanceHandles.traverseParentPath = function(start,stop,cb,arg,skipFirst,skipLast) {
	if(start == null) start = "";
	if(stop == null) stop = "";
	if(start == stop) throw "traverseParentPath(...): Cannot traverse from and to the same ID, " + start;
	var traverseUp = rx.core.InstanceHandles.isAncestorIdOf(stop,start);
	if(!traverseUp && !rx.core.InstanceHandles.isAncestorIdOf(start,stop)) throw "traverseParentPath(" + start + ", " + stop + ", ...): Cannot traverse from two IDs that do not have a parent path";
	var depth = 0;
	var traverse;
	if(traverseUp) traverse = rx.core.InstanceHandles.getParentId; else traverse = rx.core.InstanceHandles.getNextDescendantId;
	var id = start;
	while(true) {
		var ret = null;
		id = traverse(id,stop);
		if((!skipFirst || id != start) && (!skipLast || id != stop)) ret = cb(id,traverseUp,arg);
		if(ret == false || id == stop) break;
		if(depth++ >= rx.core.InstanceHandles.MAX_TREE_DEPTH) throw "traverseParentPath(" + start + ", " + stop + ", ...): Detected an infinite loop while traversing";
	}
};
rx.core.InstanceHandles.traverseAncestors = function(targetId,cb,arg) {
	rx.core.InstanceHandles.traverseParentPath("",targetId,cb,arg,true,false);
};
rx.core.InstanceHandles.isBoundary = function(id,index) {
	return id.charAt(index) == rx.core.InstanceHandles.SEPARATOR || index == id.length;
};
rx.core.InstanceHandles.isAncestorIdOf = function(ancestorId,descendantId) {
	return descendantId.indexOf(ancestorId) == 0 && rx.core.InstanceHandles.isBoundary(descendantId,ancestorId.length);
};
rx.utils.PooledClass_rx_core_MountReady = function(poolSize) {
	this.poolSize = 10;
	if(poolSize != null) this.poolSize = poolSize;
	this.pool = new Array();
};
rx.utils.PooledClass_rx_core_MountReady.__name__ = true;
rx.utils.PooledClass_rx_core_MountReady.prototype = {
	getPooled: function(arg1) {
		if(this.pool.length > 0) return this.pool.pop(); else return new rx.core.MountReady(arg1);
	}
	,release: function(instance) {
		if(Reflect.hasField(instance,"reset")) {
			var func;
			var tmp;
			if(instance == null) func = null; else if(instance.__properties__ && (tmp = instance.__properties__["get_" + "reset"])) func = instance[tmp](); else func = instance.reset;
			func.apply(instance,[]);
		}
		this.pool.push(instance);
	}
	,__class__: rx.utils.PooledClass_rx_core_MountReady
};
rx.core.MountReady = function(initalCollection) {
	this.queue = new Array();
	if(initalCollection != null) this.queue = initalCollection;
};
rx.core.MountReady.__name__ = true;
rx.core.MountReady.prototype = {
	enqueue: function(component,callback,args) {
		this.queue.push({ component : component, callback : callback, args : args});
	}
	,notifyAll: function() {
		var q = this.queue;
		if(q != null) {
			var _g = 0;
			while(_g < q.length) {
				var item = q[_g];
				++_g;
				var component = item.component;
				var callback = item.callback;
				var args = item.args;
				callback.apply(component,args);
			}
			this.queue.splice(0,this.queue.length);
		}
	}
	,reset: function() {
		this.queue.splice(0,this.queue.length);
	}
	,destruct: function() {
		this.reset();
	}
	,__class__: rx.core.MountReady
};
rx.core._Props = {};
rx.core._Props.Props_Impl_ = function() { };
rx.core._Props.Props_Impl_.__name__ = true;
rx.core._Props.Props_Impl_._new = function(a) {
	return a;
};
rx.core._Props.Props_Impl_.get = function(this1,name) {
	return this1[name];
};
rx.core._Props.Props_Impl_.keys = function(this1) {
	return Reflect.fields(this1);
};
rx.core._Props.Props_Impl_.set = function(this1,name,value) {
	this1[name] = value;
};
rx.core._Props.Props_Impl_.exists = function(this1,name) {
	return this1[name] != undefined;
};
rx.core._Props.Props_Impl_.remove = function(this1,name) {
	Reflect.deleteField(this1,name);
};
rx.core.Tools = function() { };
rx.core.Tools.__name__ = true;
rx.core.Tools.mergeInto = function(one,two) {
	var _g = 0;
	var _g1 = Reflect.fields(two);
	while(_g < _g1.length) {
		var key = _g1[_g];
		++_g;
		one[key] = two[key];
	}
};
rx.core.Tools.merge = function(one,two) {
	var result = { };
	rx.core.Tools.mergeInto(result,one);
	rx.core.Tools.mergeInto(result,two);
	return result;
};
rx.core.Updates = function() { };
rx.core.Updates.__name__ = true;
rx.core.Updates.enqueueUpdate = function(component,callback) {
	if(!rx.core.BatchingStrategy.isBatchingUpdates) {
		component.performUpdateIfNecessary();
		if(callback != null) callback.apply(component,[]);
		return;
	}
	rx.core.Updates.dirtyComponents.push(component);
	if(callback != null) {
		if(component.pendingCallbacks != null) component.pendingCallbacks.push(callback); else component.pendingCallbacks = [callback];
	}
};
rx.core.Updates.clearDirtyComponents = function() {
	rx.core.Updates.dirtyComponents = new Array();
};
rx.core.Updates.runBatchedUpdates = function() {
	rx.core.Updates.dirtyComponents.sort(function(c1,c2) {
		return c1.mountDepth - c2.mountDepth;
	});
	var _g = 0;
	var _g1 = rx.core.Updates.dirtyComponents;
	while(_g < _g1.length) {
		var component = _g1[_g];
		++_g;
		if(component.isMounted()) {
			var callbacks = component.pendingCallbacks;
			component.pendingCallbacks = null;
			component.performUpdateIfNecessary();
			if(callbacks != null) {
				var _g2 = 0;
				while(_g2 < callbacks.length) {
					var callback = callbacks[_g2];
					++_g2;
					callback.apply(component,[]);
				}
			}
		}
	}
};
rx.core.Updates.flushBatchedUpdates = function() {
	try {
		rx.core.Updates.runBatchedUpdates();
	} catch( e ) {
	}
	rx.core.Updates.clearDirtyComponents();
};
rx.core.Updates.batchedUpdates = function(callback,param) {
	rx.core.BatchingStrategy.batchUpdates(callback,param);
};
rx.utils.FlattenChildren = function() { };
rx.utils.FlattenChildren.__name__ = true;
rx.utils.FlattenChildren.flattenSingleChildIntoContext = function(traverseContext,child,name) {
	var result = traverseContext;
	if(result[name] != undefined) throw "flattenChildren(...): Incountered two children with the same key, " + name;
	if(child != null) result[name] = child;
};
rx.utils.FlattenChildren.flattenChildren = function(children) {
	if(children == null) return null;
	var result = { };
	rx.utils.TraverseChildren.traverseAllChildren(children,rx.utils.FlattenChildren.flattenSingleChildIntoContext,result);
	return result;
};
rx.utils.PooledClass = function(poolSize) {
	this.poolSize = 10;
	if(poolSize != null) this.poolSize = poolSize;
	this.pool = new Array();
};
rx.utils.PooledClass.__name__ = true;
rx.utils.PooledClass.prototype = {
	getPooled: function(arg1) {
		if(this.pool.length > 0) return this.pool.pop(); else return new rx.utils.PooledClass.T(arg1);
	}
	,release: function(instance) {
		if(Reflect.hasField(instance,"reset")) {
			var func;
			var tmp;
			if(instance == null) func = null; else if(instance.__properties__ && (tmp = instance.__properties__["get_" + "reset"])) func = instance[tmp](); else func = instance.reset;
			func.apply(instance,[]);
		}
		this.pool.push(instance);
	}
	,__class__: rx.utils.PooledClass
};
rx.utils.TraverseChildren = function() { };
rx.utils.TraverseChildren.__name__ = true;
rx.utils.TraverseChildren.userProvidedKeyEscaper = function(match) {
	return rx.utils.TraverseChildren.userProvidedKeyEscaperLookup[match];
};
rx.utils.TraverseChildren.escapeUserProvidedKey = function(text) {
	return rx.utils.TraverseChildren.userProvidedKeyEscapeRegex.replace(text,"=0");
};
rx.utils.TraverseChildren.wrapUserProvidedKey = function(key) {
	return "$" + rx.utils.TraverseChildren.userProvidedKeyEscapeRegex.replace(key,"=0");
};
rx.utils.TraverseChildren.getComponentKey = function(component,index) {
	if(component != null && component.props != null && component.props.key != null) {
		var key = component.props.key;
		return "$" + rx.utils.TraverseChildren.userProvidedKeyEscapeRegex.replace(key,"=0");
	}
	return index.toString(36);
};
rx.utils.TraverseChildren.traverseAllChildren = function(children,callback,traverseContext) {
	var _g1 = 0;
	var _g = children.length;
	while(_g1 < _g) {
		var i = _g1++;
		var child = children[i];
		var storageName;
		storageName = "." + (child != null && child.props != null && child.props.key != null?(function($this) {
			var $r;
			var key = child.props.key;
			$r = "$" + rx.utils.TraverseChildren.userProvidedKeyEscapeRegex.replace(key,"=0");
			return $r;
		}(this)):i.toString(36));
		callback(traverseContext,child,storageName,"");
	}
};
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
String.prototype.__class__ = String;
String.__name__ = true;
Array.prototype.__class__ = Array;
Array.__name__ = true;
Date.prototype.__class__ = Date;
Date.__name__ = ["Date"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
rx.browser.ui.dom.Check.Properties = { accept : null, accessKey : null, action : null, allowFullScreen : 5, allowTransparency : 1, alt : null, async : 4, autoComplete : null, autoPlay : 4, cellPadding : null, cellSpacing : null, charSet : 1, checked : 6, className : 2, cols : 17, colSpan : null, content : null, contentEditable : null, contextMenu : 1, controls : 6, crossOrigin : null, data : null, dateTime : 1, defer : 4, dir : null, disabled : 5, download : null, draggable : null, encType : null, form : 1, formNoValidate : 4, frameBorder : 1, height : 1, hidden : 5, href : null, hrefLang : null, htmlFor : null, httpEquiv : null, icon : null, id : 2, label : null, lang : null, list : null, loop : 6, max : null, maxLength : 1, mediaGroup : null, method : null, min : null, multiple : 6, muted : 6, name : null, noValidate : 4, pattern : null, placeholder : null, poster : null, preload : null, radioGroup : null, readOnly : 6, rel : null, required : 4, role : 1, rows : 17, rowSpan : null, sandbox : null, scope : null, scrollLeft : 2, scrollTop : 2, seamless : 5, selected : 6, size : 17, span : 16, spellCheck : null, src : null, srcDoc : 2, step : null, style : null, tabIndex : null, target : null, title : null, type : null, value : 10, width : 1, wmode : 1, autoCapitalize : null, autoCorrect : null, property : null, cx : 1, cy : 1, d : 1, fill : 1, fx : 1, fy : 1, gradientTransform : 1, gradientUnits : 1, offset : 1, points : 1, r : 1, rx : 1, ry : 1, spreadMethod : 1, stopColor : 1, stopOpacity : 1, stroke : 1, strokeLinecap : 1, strokeWidth : 1, transform : 1, version : 1, viewBox : 1, x1 : 1, x2 : 1, x : 1, y1 : 1, y2 : 1, y : 1};
rx.browser.ui.dom.Check.DOMAttributeNames = { className : "class", gradientTransform : "gradientTransform", gradientUnits : "gradientUnits", htmlFor : "for", spreadMethod : "spreadMethod", stopColor : "stop-color", stopOpacity : "stop-opacity", strokeLinecap : "stroke-linecap", strokeWidth : "stroke-width", viewBox : "viewBox"};
rx.browser.ui.dom.Check.DOMPropertyNames = { autoCapitalize : "autocapitalize", autoComplete : "autocomplete", autoCorrect : "autocorrect", autoFocus : "autofocus", autoPlay : "autoplay", encType : "enctype", hrefLang : "hreflang", radioGroup : "radiogroup", spellCheck : "spellcheck", srcDoc : "srcdoc"};
rx.event.EventPluginRegistry.registrationNameModules = { };
rx.event.EventPluginHub.registrationNameModules = rx.event.EventPluginRegistry.registrationNameModules;
rx.browser.EventEmitter.registrationNameModules = rx.event.EventPluginHub.registrationNameModules;
rx.browser.PutListenerQueue.pool = new rx.utils.PooledClass_rx_browser_PutListenerQueue();
rx.browser.ReconcileTransaction.pool = new rx.utils.PooledClass_rx_browser_ReconcileTransaction();
rx.browser.RootIndex._rootIndex = 0;
rx.browser.ui.DOM.emptyDescriptor = new rx.core.Descriptor(null,null);
rx.browser.ui.DOM.tagsMap = { a : false, b : false, button : false, form : false, div : false, span : false};
rx.browser.ui.Mount.totalInstantiationTime = 0;
rx.browser.ui.Mount.totalInjectionTime = 0;
rx.browser.ui.Mount.ATTR_NAME = "data-reactid";
rx.browser.ui.Mount.DOC_NODE_TYPE = 9;
rx.browser.ui.Mount.nodeCache = { };
rx.browser.ui.Mount.findComponentRootReusableArray = new Array();
rx.browser.ui.Mount.containersByReactRootId = { };
rx.browser.ui.Mount.SEPARATOR = ".";
rx.browser.ui.Mount.instancesByReactRootId = { };
rx.core.ContainerComponent.updateDepth = 0;
rx.core.ContainerComponent.updateQueue = new Array();
rx.core.ContainerComponent.markupQueue = new Array();
rx.browser.ui.dom.Component.ELEMENT_NODE_TYPE = 1;
rx.browser.ui.dom.Danger.OPEN_TAG_NAME_EXP = new EReg("^(<[^ />]+)","");
rx.browser.ui.dom.Danger.RESULT_INDEX_ATTR = "data-danger-index";
rx.browser.ui.dom.Danger.dummyNode = window.document.createElement("div");
rx.browser.ui.dom.Check.MUST_USE_ATTRIBUTE = 1;
rx.browser.ui.dom.Check.MUST_USE_PROPERTY = 2;
rx.browser.ui.dom.Check.HAS_BOOLEAN_VALUE = 4;
rx.browser.ui.dom.Check.HAS_SIDE_EFFECTS = 8;
rx.browser.ui.dom.Check.HAS_POSITIVE_NUMERIC_VALUE = 16;
rx.browser.ui.dom.Property.ID_ATTRIBUTE_NAME = "data-reactid";
rx.browser.ui.dom.Property.defaultValueCache = { };
rx.core.BatchingStrategy.isBatchingUpdates = false;
rx.core.BatchingStrategy.transaction = new rx.core.BatchingTransaction();
rx.core.InstanceHandles.SEPARATOR = ".";
rx.core.InstanceHandles.MAX_TREE_DEPTH = 100;
rx.core.MountReady.pool = new rx.utils.PooledClass_rx_core_MountReady();
rx.core.Updates.dirtyComponents = new Array();
rx.utils.TraverseChildren.userProvidedKeyEscaperLookup = { '=' : "=0", '.' : "=1", ':' : "=2"};
rx.utils.TraverseChildren.userProvidedKeyEscapeRegex = new EReg("[=.:]","g");
rx.utils.TraverseChildren.SEPARATOR = ".";
rx.utils.TraverseChildren.SUBSEPARATOR = ":";
App.main();
})();
