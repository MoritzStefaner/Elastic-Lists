/**
 * SWFAddress 2.1: Deep linking for Flash and Ajax - http://www.asual.com/swfaddress/
 *
 * SWFAddress is (c) 2006-2007 Rostislav Hristov and is released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 *
 */

if (typeof com == "undefined") var com = {};
if (typeof com.asual == "undefined") com.asual = {};
if (typeof com.asual.util == "undefined") com.asual.util = {};
   
/**
 * @class Utility class that provides detailed browser information.
 * @static
 * @ignore
 */
com.asual.util.Browser = new function() {

    var _version = -1;
    var _agent = navigator.userAgent;
    var _ie = false, _camino = false, _safari = false, _opera = false, 
        _firefox = false, _netscape = false, _mozilla = false;

    var _getVersion = function(s, i) {
        return parseFloat(_agent.substr(_agent.indexOf(s) + i));
    }
    
    if (_ie = /MSIE/.test(_agent))
        _version = _getVersion('MSIE', 4);
        
    if (_safari = /AppleWebKit/.test(_agent))
        _version = _getVersion('Safari', 7);
        
    if (_opera = /Opera/.test(_agent))
        _version = parseFloat(navigator.appVersion);
        
    if (_camino = /Camino/.test(_agent))
        _version = _getVersion('Camino', 7);
        
    if (_firefox = /Firefox/.test(_agent))
        _version = _getVersion('Firefox', 8);
        
    if (_netscape = /Netscape/.test(_agent))
        _version = _getVersion('Netscape', 9);
        
    if (_mozilla = /Mozilla/.test(_agent) && /rv:/.test(_agent))
        _version = _getVersion('rv:', 3);


    /**
     * Detects the version of the browser.
     * @return {Number}
     * @static
     */
    this.getVersion = function() {
        return _version;
    }

    /**
     * Detects if the browser is Internet Explorer.
     * @return {Boolean}
     * @static
     */
    this.isIE = function() {
        return _ie;
    }

    /**
     * Detects if the browser is Safari.
     * @return {Boolean}
     * @static
     */
    this.isSafari = function() {
        return _safari;
    }

    /**
     * Detects if the browser is Opera.
     * @return {Boolean}
     * @static
     */
    this.isOpera = function() {
        return _opera;
    }

    /**
     * Detects if the browser is Camino.
     * @return {Boolean}
     * @static
     */
    this.isCamino = function() {
        return _camino;
    }

    /**
     * Detects if the browser is Firefox.
     * @return {Boolean}
     * @static
     */
    this.isFirefox = function() {
        return _firefox;
    }

    /**
     * Detects if the browser is Netscape.
     * @return {Boolean}
     * @static
     */
    this.isNetscape = function() {
        return _netscape;
    }
        
    /**
     * Detects if the browser is Mozilla.
     * @return {Boolean}
     * @static
     */
    this.isMozilla = function() {
        return _mozilla;
    }
}

/**
 * @class Utility class that provides event helpers.
 * @static
 * @ignore
 */
com.asual.util.Events = new function() {

    var _cache = [];
    var _browser = com.asual.util.Browser;
    var _dcl = 'DOMContentLoaded';

    if (_browser.isIE() || _browser.isSafari()) {
        (function (){
            try {
                if (_browser.isIE() || !/loaded|complete/.test(document.readyState))
                    document.documentElement.doScroll('left');
            } catch(e) {
                return setTimeout(arguments.callee, 0);
            }
            for (var i = 0, e; e = _cache[i]; i++)
                if (e.t == _dcl) e.l.call(null);
        })();
    }

    /**
     * Adds an event listener to an object.
     * @param {Object} obj The object that provides events.
     * @param {String} type The type of the event.
     * @param {Function} listener The event listener function.
     * @return {void}
     * @static
     */
    this.addListener = function(obj, type, listener) {
        _cache.push({o: obj, t: type, l: listener});
        if (!(type == _dcl && (_browser.isIE() || _browser.isSafari()))) {
            if (obj.addEventListener)
                obj.addEventListener(type, listener, false);
            else if (obj.attachEvent)
                obj.attachEvent('on' + type, listener);
        }
    }

    /**
     * Removes an event listener from an object.
     * @param {Object} obj The object that provides events.
     * @param {String} type The type of the event.
     * @param {Function} listener The event listener function.
     * @return {void}     
     * @static
     */
    this.removeListener = function(obj, type, listener) {
        for (var i = 0, e; e = _cache[i]; i++) {
            if (e.o == obj && e.t == type && e.l == listener) {
                _cache.splice(i, 1);
                break;
            }
        }
        if (!(type == _dcl && (_browser.isIE() || _browser.isSafari()))) {
            if (obj.removeEventListener)
                obj.removeEventListener(type, listener, false);
            else if (obj.detachEvent)
                obj.detachEvent('on' + type, listener);
        }
    }

    var _unload = function() {
        for (var i = 0, evt; evt = _cache[i]; i++) {
            if (evt.t != _dcl)
                com.asual.util.Events.removeListener(evt.o, evt.t, evt.l);
        }
    }

    this.addListener(window, 'unload', _unload);
}

/**
 * Creates a new SWFAddress event.
 * @class Event class for SWFAddress.
 * @param {String} type Type of the event.
 */
SWFAddressEvent = function(type) {
    
    /**
     * String representation of this object.
     * @ignore
     */
    this.toString = function() {
        return '[object SWFAddressEvent]';
    }

    /**
     * The type of this event.
     * @type String
     */
    this.type = type;

    /**
     * The target of this event.
     * @type Function
     */
    this.target = [SWFAddress][0];

    /**
     * The value of this event.
     * @type String
     */
    this.value = SWFAddress.getValue();

    /**
     * The path of this event.
     * @type String
     */
    this.path = SWFAddress.getPath();
    
    /**
     * The folders in the deep linking path of this event.
     * @type Array
     */
    this.pathNames = SWFAddress.getPathNames();

    /**
     * The parameters of this event.
     * @type Object
     */
    this.parameters = {};

    var _parametersNames = SWFAddress.getParameterNames();
    for (var i = 0, l = _parametersNames.length; i < l; i++)
        this.parameters[_parametersNames[i]] = SWFAddress.getParameter(_parametersNames[i]);
    
    /**
     * The parameters names of this event.
     * @type Array     
     */
     this.parametersNames = _parametersNames;
}

/**
 * Init event.
 * @type String
 * @memberOf SWFAddressEvent
 * @static
 */
SWFAddressEvent.INIT = 'init';

/**
 * Change event.
 * @type String
 * @memberOf SWFAddressEvent
 * @static 
 */
SWFAddressEvent.CHANGE = 'change';

/**
 * @class The SWFAddress class can be configured with query parameters using the following format:
 * swfaddress.js?html=false&history=1&tracker=pageTracker._trackPageview&strict=1.<br /> 
 * The list of supported options include:<br /><br />
 * <code>history:Boolean</code> - Enables or disables the creation of history entries.<br />
 * <code>html:Boolean</code> - Enables or disables the usage of swfaddress.html.<br />
 * <code>strict:Boolean</code> - Enables or disables the strict mode.<br />
 * <code>tracker:String</code> - Sets a function for page view tracking.<br />
 * @static 
 */ 
SWFAddress = new function() {

    var _browser = com.asual.util.Browser;
    var _events = com.asual.util.Events;
    var _version = _browser.getVersion();
    var _supported = false;

    if (_browser.isIE()) 
        _supported = _version >= 6;
        
    if (_browser.isSafari())
        _supported = _version >= 312;
        
    if (_browser.isOpera())
        _supported = _version >= 9.02;
        
    if (_browser.isCamino()) 
        _supported = _version >= 1;
        
    if (_browser.isFirefox())
        _supported = _version >= 1;
        
    if (_browser.isNetscape())
        _supported = _version >= 8;
        
    if (_browser.isMozilla())
        _supported = _version >= 1.8;

    var _t = top;
    var _d = _t.document;
    var _h = _t.history;
    var _l = _t.location;
    var _st = setTimeout;
    
    var FUNCTION = 'function';
    var UNDEFINED = 'undefined';
    var SWFADDRESS = 'swfaddress';

    var _iframe, _form, _url;
    var _title = _d.title;
    var _length = _h.length;
    var _silent = false;
    var _listeners = {};
    var _stack = [];
    var _ids = [];
    
    var _opts = {};
    _opts.history = true;
    _opts.html = false;
    _opts.strict = true;
    _opts.tracker = '_trackDefault';
    
    if ((!_supported && _l.href.indexOf('#') != -1) || 
        (_browser.isSafari() && _version < 412 && _l.href.indexOf('#') != -1 && _l.search != '')){
        _d.open();
        _d.write('<html><head><meta http-equiv="refresh" content="0;url=' + 
            _l.href.substr(0, _l.href.indexOf('#')) + '" /></head></html>');
        _d.close();
    }

    var _getHash = function() {
        var index = _l.href.indexOf('#');
        if (index != -1) {
            var hash = unescape(_l.href.substr(index + 1));
            if (/^[a-z0-9 ,=_&\-\.\?\+\/]*$/i.test(hash))
                return hash;
            else
                _l.replace(_l.href.substr(0, index));
        }
        return '';
    }

    var _value = _getHash();

    var _strictCheck = function(value, force) {
        if (_opts.strict)
            value = force ? (value.substr(0, 1) != '/' ? '/' + value : value) : (value == '' ? '/' : value);
        return value;
    }

    var _ieLocal = function(value) {
        return (_browser.isIE() && _l.protocol == 'file:') ? _value.replace(/\?/, '%3F') : value;    
    }

    var _searchScript = function(el) {
        if (el.src && /swfaddress\.js(\?.*)?$/.test(el.src)) return el;
        for (var i = 0, l = el.childNodes.length, s; i < l; i++)
            if (s = _searchScript(el.childNodes[i])) return s;
    }
    
    var _titleCheck = function() {
        if (_browser.isIE() && _d.title != _title)
            SWFAddress.setTitle(_title);
    }

    var _listen = function() {
        if (!_silent) {
            var hash = _getHash();
            if (_browser.isIE()) {
                if (_value != hash) {
                    if (_version < 7)
                        _l.reload();
                    else
                        SWFAddress.setValue(hash);
                }
            } else if (_browser.isSafari() && _version < 523) {
                if (_length != _h.length) {
                    _length = _h.length;
                    if (typeof _stack[_length - 1] != UNDEFINED)
                        _value = _stack[_length - 1];
                    _update();
                }
            } else if (_value != hash) {
                _value = hash;
                _update();
            }
            _titleCheck();
        }
    }

    var _jsDispatch = function(type) {
        if (SWFAddress.hasEventListener(type))
            SWFAddress.dispatchEvent(new SWFAddressEvent(type));
        type = type.substr(0, 1).toUpperCase() + type.substr(1);
        if(typeof SWFAddress['on' + type] == FUNCTION)
            SWFAddress['on' + type]();
    }

    var _jsInit = function() {
        _jsDispatch('init');
    }

    var _jsChange = function() {
        _jsDispatch('change');
    }

    var _swfChange = function() {
        for (var i = 0, id, value = SWFAddress.getValue(), setter = 'setSWFAddressValue'; id = _ids[i]; i++) {
            var obj = document.getElementById(id);
            if (obj) {
                if (obj.parentNode && typeof obj.parentNode.so != UNDEFINED) {
                    obj.parentNode.so.call(setter, value);
                } else {
                    if (!(obj && typeof obj[setter] != UNDEFINED)) {
                        var objects = obj.getElementsByTagName('object');
                        var embeds = obj.getElementsByTagName('embed');
                        obj = ((objects[0] && typeof objects[0][setter] != UNDEFINED) ? 
                            objects : ((embeds[0] && typeof embeds[0][setter] != UNDEFINED) ? 
                                embeds[0] : null));
                    }
                    if (obj)
                        obj[setter](value);
                } 
            } else if (obj = document[id]) {
                if (typeof obj[setter] != UNDEFINED)
                    obj[setter](value);
            }
        }
    }

    var _update = function() {
        _swfChange();
        _jsChange();
        _st(_track, 10);
    }

    var _trackDefault = function(value) {
        if (typeof urchinTracker == FUNCTION) 
            urchinTracker(value);
        if (typeof pageTracker != UNDEFINED && typeof pageTracker._trackPageview == FUNCTION)
            pageTracker._trackPageview(value);
    }
    
    eval('var _trackDefault = ' + _trackDefault + ';');
    
    var _track = function() {
        if (typeof _opts.tracker != UNDEFINED && eval('typeof ' + _opts.tracker + ' != "' + UNDEFINED + '"')) {
            var fn = eval(_opts.tracker);
            if (typeof fn == FUNCTION)
                fn((_l.pathname + (/\/$/.test(_l.pathname) ? '' : '/') + SWFAddress.getValue()).replace(/\/\//, '/').replace(/^\/$/, ''));
        }
    }
    
    var _htmlWrite = function() {
        var doc = _iframe.contentWindow.document;
        doc.open();
        doc.write('<script>var ' + SWFADDRESS + ' = "' + _getHash() + '";</script>');
        doc.close();
    }

    var _htmlLoad = function() {
        var win = _iframe.contentWindow;
        if (_opts.html) {
            var src = win.location.href;
            _value = (src.indexOf('?') > -1) ? src.substr(src.indexOf('?') + 1) : '';
        } else {
            _value = (typeof win[SWFADDRESS] != UNDEFINED) ? win[SWFADDRESS] : '';
        }
        win.document.title = _d.title;
        if (_value != _getHash()) {
            _update();
            _l.hash = _ieLocal(_value);
        }
    }

    var _load = function() {
        var attr = 'id="' + SWFADDRESS + '" style="position:absolute;top:-9999px;"';
        if (_browser.isIE()) {
            document.body.appendChild(document.createElement('div')).innerHTML = '<iframe ' + attr + ' src="' + 
                (_opts.html ? _url.replace(/\.js(\?.*)?$/, '.html') + '?' + _getHash() : 'javascript:false;') + 
                '" width="0" height="0"></iframe>';
            _iframe = document.getElementById(SWFADDRESS);
            _st(function() {
                _events.addListener(_iframe, 'load', _htmlLoad);            
                if (!_opts.html && typeof _iframe.contentWindow[SWFADDRESS] == UNDEFINED) 
                    _htmlWrite();
            }, 10);
        } else if (_browser.isSafari()) {
            if (_version < 412) {
                document.body.innerHTML += '<form ' + attr + ' method="get"></form>';
                _form = document.getElementById(SWFADDRESS);
            }
            if (typeof _l[SWFADDRESS] == UNDEFINED) _l[SWFADDRESS] = {};
            if (typeof _l[SWFADDRESS][_l.pathname] != UNDEFINED) _stack = _l[SWFADDRESS][_l.pathname].split(',');
        } else if (_browser.isOpera() && _ids.length == 0 && typeof navigator.plugins['Shockwave Flash'] == 'object') {
            document.body.innerHTML += '<embed ' + attr + ' src="' + _url.replace(/\.js(\?.*)?$/, '.swf') + 
                '" type="application/x-shockwave-flash" />';
        }
        _st(_jsInit, 1);
        _st(_jsChange, 2);
        _st(_track, 10);
        setInterval(_listen, 50);
    }

    /**
     * Init event.
     * @type Function
     * @event
     * @static
     */
    this.onInit = null;
    
    /**
     * Change event.
     * @type Function
     * @event
     * @static
     */
    this.onChange = null;
    
    /**
     * String representation of this class.
     * @ignore
     */
    this.toString = function() {
        return '[class SWFAddress]';
    }

    /**
     * Loads the previous URL in the history list.
     * @return {void}
     * @static
     */
    this.back = function() {
        _h.back();
    }

    /**
     * Loads the next URL in the history list.
     * @return {void}
     * @static
     */
    this.forward = function() {
        _h.forward();
    }

    /**
     * Loads a URL from the history list.
     * @param {Number} delta An integer representing a relative position in the history list.
     * @return {void}
     * @static
     */
    this.go = function(delta) {
        _h.go(delta);
    }

    /**
     * Opens a new URL in the browser. 
     * @param {String} url The resource to be opened.
     * @param {String} target Target window.
     * @return {void}
     * @static
     */
    this.href = function(url, target) {
        target = (typeof target != UNDEFINED) ? target : '_self';     
        if (target == '_self')
            self.location.href = url; 
        if (target == '_top')
            _l.href = url; 
        if (target == '_blank')
            window.open(url); 
        else
            _t.frames[target].location.href = url; 
    }

    /**
     * Opens a browser popup window. 
     * @param {String} url Resource location.
     * @param {String} name Name of the popup window.
     * @param {String} options Options which get evaluted and passed to the window.open() method.
     * @param {String} handler Optional JavaScript code for popup handling.    
     * @return {void}
     * @static
     */
    this.popup = function(url, name, options, handler) {
        var popup = window.open(url, name, eval(options));
        eval(handler);
    }

    /**
     * Registers an event listener.
     * @param {String} type Event type.
     * @param {Function} listener Event listener.
     * @return {void}
     * @static
     */
    this.addEventListener = function(type, listener) {
        if (typeof _listeners[type] == UNDEFINED)
            _listeners[type] = [];
        _listeners[type].push(listener);
    }

    /**
     * Removes an event listener.
     * @param {String} type Event type.
     * @param {Function} listener Event listener.
     * @return {void}
     * @static     
     */
    this.removeEventListener = function(type, listener) {
        if (typeof _listeners[type] != UNDEFINED) {
            for (var i = 0, l; l = _listeners[type][i]; i++)
                if (l == listener) break;
            _listeners[type].splice(i, 1);
        }
    }

    /**
     * Dispatches an event to all the registered listeners. 
     * @param {Object} event Event object.
     * @return {Boolean}
     * @static
     */
    this.dispatchEvent = function(event) {
        if (typeof _listeners[event.type] != UNDEFINED && _listeners[event.type].length) {
            event.target = this;
            for (var i = 0, l; l = _listeners[event.type][i]; i++)
                l(event);
            return true;           
        }
        return false;
    }

    /**
     * Checks the existance of any listeners registered for a specific type of event. 
     * @param {String} event Event type.
     * @return {Boolean}
     * @static
     */
    this.hasEventListener = function(type) {
        return (typeof _listeners[type] != UNDEFINED && _listeners[type].length > 0);
    }
    
    /**
     * Provides the base address of the document. 
     * @return {String}
     * @static
     */
    this.getBaseURL = function() {
        var url = _l.href;
        if (url.indexOf('#') != -1)
            url = url.substr(0, url.indexOf('#'));
        if (url.substr(url.length - 1) == '/')
            url = url.substr(0, url.length - 1);
        return url;
    }

    /**
     * Provides the state of the strict mode setting. 
     * @return {Boolean}
     * @static
     */
    this.getStrict = function() {
        return _opts.strict;
    }

    /**
     * Enables or disables the strict mode.
     * @param {Boolean} strict Strict mode state.
     * @return {void}
     * @static
     */
    this.setStrict = function(strict) {
        _opts.strict = strict;
    }

    /**
     * Provides the state of the history setting. 
     * @return {Boolean}
     * @static
     */
    this.getHistory = function() {
        return _opts.history;
    }

    /**
     * Enables or disables the creation of history entries.
     * @param {Boolean} history History state.
     * @return {void}
     * @static
     */
    this.setHistory = function(history) {
        _opts.history = history;
    }

    /**
     * Provides the tracker function.
     * @return {String}
     * @static
     */
    this.getTracker = function() {
        return _opts.tracker;
    }

    /**
     * Sets a function for page view tracking. The default value is 'urchinTracker'.
     * @param {String} tracker Tracker function.
     * @return {void}
     * @static
     */
    this.setTracker = function(tracker) {
        _opts.tracker = tracker;
    }

    /**
     * Provides a list of all the Flash objects registered. 
     * @return {Array}
     * @static
     */
    this.getIds = function() {
        return _ids;
    }

    /**
     * Provides the id the first and probably the only Flash object registered. 
     * @return {String}
     * @static
     */
    this.getId = function(index) {
        return _ids[0];
    }

    /**
     * Sets the id of a single Flash object which will be registered for deep linking.
     * @param {String} id ID of the object.
     * @return {void}
     * @static
     */
    this.setId = function(id) {
        _ids[0] = id;
    }

    /**
     * Adds an id to the list of Flash object registered for deep linking.
     * @param {String} id ID of the object.
     * @return {void}
     * @static
     */
    this.addId = function(id) {
        this.removeId(id);
        _ids.push(id);
    }

    /**
     * Removes an id from the list of Flash object registered for deep linking.
     * @param {String} id ID of the object.
     * @return {void}
     * @static
     */
    this.removeId = function(id) {
        for (var i = 0; i < _ids.length; i++) {
            if (id == _ids[i]) {
                _ids.splice(i, 1);
                break;
            }
        }
    }

    /**
     * Provides the title of the HTML document.
     * @return {String}
     * @static
     */
    this.getTitle = function() {
        return _d.title;
    }

    /**
     * Sets the title of the HTML document.
     * @param {String} title Title value.
     * @return {void}
     * @static
     */
    this.setTitle = function(title) {
        if (!_supported) return null;
        if (typeof title == UNDEFINED) return;
        if (title == 'null') title = '';
        _title = _d.title = title;
        _st(function() {
            if (_iframe && _iframe.contentWindow && _iframe.contentWindow.document && _iframe.contentWindow.title)
                _iframe.contentWindow.document.title = _title;
         }, 1000);
    }

    /**
     * Provides the status of the browser window.
     * @return {String}
     * @static
     */
    this.getStatus = function() {
        return _t.status;
    }

    /**
     * Sets the status of the browser window.
     * @param {String} status Status value.
     * @return {void}
     * @static
     */
    this.setStatus = function(status) {
        if (!_supported) return null;
        if (typeof status == UNDEFINED) return;
        if (!_browser.isSafari()) {
            status = _strictCheck((status != 'null') ? status : '', true);
            if (status == '/') status = '';
            if (!(/http(s)?:\/\//.test(status))) {
                var index = _l.href.indexOf('#');
                status = (index == -1 ? _l.href : _l.href.substr(0, index)) + '#' + status;
            }
            _t.status = status;
        }
    }

    /**
     * Resets the status of the browser window.
     * @return {void}
     * @static
     */
    this.resetStatus = function() {
        _t.status = '';
    }

    /**
     * Provides the current deep linking value.
     * @return {String}
     * @static
     */
    this.getValue = function() {
        if (!_supported) return null;
        return _strictCheck(_value, false);
    }

    /**
     * Sets the current deep linking value.
     * @param {String} value A value which will be appended to the base link of the HTML document.
     * @return {void}
     * @static
     */
    this.setValue = function(value) {
        if (!_supported) return null;
        if (typeof value == UNDEFINED) return;
        if (value == 'null') value = ''
        value = _strictCheck(value, true);
        if (value == '/') value = '';
        if (_value == value) return;
        _value = value;
        _silent = true;
        _update();
        _stack[_h.length] = _value;
        if (_browser.isSafari()) {
            if (_opts.history) {
                _l[SWFADDRESS][_l.pathname] = _stack.toString();
                _length = _h.length + 1;
                if (_version < 412) {
                    if (_l.search == '') {
                        _form.action = '#' + _value;
                        _form.submit();
                    }
                } else if (_version < 523){
                    var evt = document.createEvent('MouseEvents');
                    evt.initEvent('click', true, true);
                    var anchor = document.createElement('a');
                    anchor.href = '#' + _value;
                    anchor.dispatchEvent(evt);                
                } else {
                    _l.hash = '#' + _value;
                }
            } else {
                _l.replace('#' + _value);
            }
        } else if (_value != _getHash()) {
            if (_opts.history)
                _l.hash = '#' + _ieLocal(_value);
            else
                _l.replace('#' + _value);
        }
        if (_browser.isIE() && _opts.history) {
            if (_opts.html) {
                var loc = _iframe.contentWindow.location;
                loc.assign(loc.pathname + '?' + _getHash());
            } else {
                _htmlWrite();
            }
        }
        if (_browser.isSafari())
            _st(function(){ _silent = false; }, 1);
        else
            _silent = false;
    }

    /**
     * Provides the deep linking value without the query string.
     * @return {String}
     * @static
     */
    this.getPath = function() {
        var value = this.getValue();
        return (value.indexOf('?') != -1) ? value.split('?')[0] : value;
    }

    /**
     * Provides a list of all the folders in the deep linking path.
     * @return {Array}
     * @static
     */
    this.getPathNames = function() {
        var path = SWFAddress.getPath();
        var names = path.split('/');
        if (path.substr(0, 1) == '/')
            names.splice(0, 1);
        if (path.substr(path.length - 1, 1) == '/')
            names.splice(names.length - 1, 1);
        return names;
    }

    /**
     * Provides the query string part of the deep linking value.
     * @return {String}
     * @static
     */
    this.getQueryString = function() {
        var value = this.getValue();
        var index = value.indexOf('?');
        return (index != -1 && index < value.length) ? value.substr(index + 1) : '';
    }

    /**
     * Provides the value of a specific query parameter.
     * @param {String} param Parameter name.
     * @return {String}
     * @static
     */
    this.getParameter = function(param) {
        var value = this.getValue();
        var index = value.indexOf('?');
        if (index != -1) {
            value = value.substr(index + 1);
            var params = value.split('&');
            var p, i = params.length;
            while(i--) {
                p = params[i].split('=');
                if (p[0] == param)
                    return p[1];
            }
        }
        return '';
    }

    /**
     * Provides a list of all the query parameter names.
     * @return {Array}
     * @static
     */
    this.getParameterNames = function() {
        var value = this.getValue();
        var index = value.indexOf('?');
        var names = [];
        if (index != -1) {
            value = value.substr(index + 1);
            if (value != '' && value.indexOf('=') != -1) {
                var params = value.split('&');
                var i = 0;
                while(i < params.length) {
                    names.push(params[i].split('=')[0]);
                    i++;
                }
            }
        }
        return names;
    }

    if (_supported) {
    
        for (var i = 1; i < _length; i++)
            _stack.push('');
            
        _stack.push(_getHash());
    
        if (_browser.isIE() && _l.hash != _getHash())
            _l.hash = '#' + _ieLocal(_getHash());
    
        try {
            _url = String(_searchScript(document).src);
            var qi = _url.indexOf('?');
            if (_url && qi > -1) {
                var param, params = _url.substr(qi + 1).split('&');
                for (var i = 0, p; p = params[i]; i++) {
                    param = p.split('=');
                    if (/^(history|html|strict)$/.test(param[0]))
                        _opts[param[0]] = (isNaN(param[1]) ? eval(param[1]) : (parseFloat(param[1]) > 0));
                    if (/^tracker$/.test(param[0]))
                        _opts[param[0]] = param[1];
                }
            }
        } catch(e) {}
        if (/file:\/\//.test(_l.href)) _opts.html = false;
    
        _titleCheck();
        _events.addListener(document, 'DOMContentLoaded', _load);
    
    } else {
        _track();
    }
}

/**
 * SWFAddress embed hooks.
 * @ignore
 */
new function() {

    var _func, _args;
    var UNDEFINED = 'undefined';

    if (typeof swfobject != UNDEFINED) SWFObject = swfobject;
    if (typeof FlashObject != UNDEFINED) SWFObject = FlashObject;
    
    if (typeof SWFObject != UNDEFINED) {
        if (SWFObject.prototype && SWFObject.prototype.write) {
            _func = SWFObject.prototype.write;
            SWFObject.prototype.write = function() {
                _args = arguments;
                if (this.getAttribute('version').major < 8) {
                    this.addVariable('$swfaddress', SWFAddress.getValue());
                    ((typeof _args[0] == 'string') ? 
                        document.getElementById(_args[0]) : _args[0]).so = this;
                }
                var success;
                if (success = _func.apply(this, _args))
                    SWFAddress.addId(this.getAttribute('id'));
                return success;
            }
        } else {
            _func = SWFObject.registerObject;
            SWFObject.registerObject = function() {
                _args = arguments;
                _func.apply(this, _args);
                SWFAddress.addId(_args[0]);            
            }
            _func = SWFObject.createSWF;
            SWFObject.createSWF = function() {
                _args = arguments;
                _func.apply(this, _args);
                SWFAddress.addId(_args[0].id);            
            }
            _func = SWFObject.embedSWF;
            SWFObject.embedSWF = function() {
                _args = arguments;
                _func.apply(this, _args);
                SWFAddress.addId(_args[8].id);            
            }
        }
    }
    
    if (typeof UFO != UNDEFINED) {
        _func = UFO.create;
        UFO.create = function() {
            _args = arguments;
            _func.apply(this, _args);
            SWFAddress.addId(_args[0].id);        
        }
    }
    
    if (typeof AC_FL_RunContent != UNDEFINED) {
        _func = AC_FL_RunContent;
        AC_FL_RunContent = function() {
            _args = arguments;        
            _func.apply(this, _args);
            for (var i = 0, l = _args.length; i < l; i++)
                if (_args[i]== 'id') SWFAddress.addId(_args[i+1]);
        }
    }
}