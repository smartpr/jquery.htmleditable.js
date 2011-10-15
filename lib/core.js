(function() {
  /**
  
  # core
  
  The core editor *engine* jQuery plugin.
  
  */
  "use strict";
  var $, $rinsebin, getRinsebin, getState, overriddenHtml, setState, updateState, _ref;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  }, __slice = Array.prototype.slice;
  $ = jQuery;
  $.expr[':'].htmleditable = function(el) {
    var $el;
    $el = $(el);
    return $el.is('[contenteditable="true"]') && ($el.data('htmleditable') != null);
  };
  overriddenHtml = $.fn.html;
  $.fn.html = function(html) {
    var $decoder, $editable, cursor, element, elementProcess, feature, features, forceRemove, name, p, process, remove, result, _i, _j, _len, _len2, _ref, _ref2;
    if (this[0] === getRinsebin()[0] && !(html != null)) {
      html = overriddenHtml.call(this);
      $editable = $(':htmleditable:first');
      features = $editable.data('htmleditable').features;
      for (name in features) {
        feature = features[name];
        result = feature != null ? (_ref = feature.input) != null ? _ref.call($editable, html) : void 0 : void 0;
        if (typeof result === 'string') {
          html = result;
        }
      }
      $decoder = $('<div />');
      cursor = this.empty()[0];
      process = [];
      HTMLParser(html, {
        start: function(name, attrs, empty) {
          var $element, element, elementProcess, feature, remove, _ref2;
          try {
            element = document.createElement(name);
          } catch (err) {

          }
          if (!element) {
            return;
          }
          $element = $(element);
          element = void 0;
          elementProcess = [];
          for (name in features) {
            feature = features[name];
            result = feature != null ? (_ref2 = feature.allow) != null ? _ref2.call($element, attrs) : void 0 : void 0;
            if ($.isFunction(result)) {
              elementProcess.push(result);
            } else if (!element) {
              if (result === true) {
                element = $element[0];
              }
              if ((result != null ? result.nodeType : void 0) === 1) {
                element = result;
              }
            }
          }
          if (elementProcess.length > 0) {
            remove = !(element != null);
            if (element == null) {
              element = $element[0];
            }
            process.push([element, elementProcess, remove]);
          }
          if (!element) {
            return;
          }
          cursor.appendChild(element);
          if (!(element.nodeName in empty)) {
            cursor = element;
          }
          return true;
        },
        end: function(name) {
          return cursor = cursor.parentNode;
        },
        chars: function(text) {
          return cursor.appendChild(document.createTextNode($decoder.html(text).text()));
        }
      });
      for (_i = 0, _len = process.length; _i < _len; _i++) {
        _ref2 = process[_i], element = _ref2[0], elementProcess = _ref2[1], remove = _ref2[2];
        forceRemove = false;
        for (_j = 0, _len2 = elementProcess.length; _j < _len2; _j++) {
          p = elementProcess[_j];
          forceRemove = forceRemove || p.call(this, element, remove) === true;
        }
        if (forceRemove || remove) {
          $(element).domSplice();
        }
      }
      return overriddenHtml.call(this);
    }
    if (this.eq(0).is(':htmleditable')) {
      if (html == null) {
        return this.data('htmleditable').value;
      }
      html = html.replace(/^([\s\S]*)<!--htmleditable:state\s([\s\S]*?)-->([\s\S]*)$/g, __bind(function(match, before, settings, after) {
        var name, value, _ref3, _ref4;
        features = this.data('htmleditable').features;
        _ref3 = $.parseJSON("{ " + settings + " }");
        for (name in _ref3) {
          value = _ref3[name];
          if (((_ref4 = features[name]) != null ? _ref4.content : void 0) === true) {
            this.htmleditable('command', name, value);
          }
        }
        return before + after;
      }, this));
      html = getRinsebin().html(html).html();
      getRinsebin().empty();
      result = overriddenHtml.call(this, html);
      updateValue.call(this[0]);
      return result;
    }
    return overriddenHtml.call(this, html);
  };
  window.updateValue = function() {
    var $current, current, data, feature, name, settings, _ref, _ref2;
    data = $(this).data('htmleditable');
    $current = $(this).clone(false, false);
    settings = {};
    _ref = data.features;
    for (name in _ref) {
      feature = _ref[name];
      if ((_ref2 = feature.output) != null) {
        _ref2.call($(this), $current);
      }
      if (feature.content === true) {
        settings[name] = $(this).htmleditable('state', name);
      }
    }
    current = $current.html();
    if (!$.isPlainObject(settings)) {
      settings = JSON.stringify(settings);
      current = "<!--htmleditable:state " + settings.slice(1, settings.length - 1) + " -->" + current;
    }
    if (data.value !== current) {
      data.value = current;
      return $(this).change();
    }
  };
  getState = function(inactive) {
    var feature, featureState, name, selection, state, value, _ref, _ref2, _ref3;
    selection = $(this).htmleditable('selection');
    state = {};
    _ref = $(this).data('htmleditable').features;
    for (name in _ref) {
      feature = _ref[name];
      featureState = feature != null ? (_ref2 = feature.context) != null ? (_ref3 = _ref2.get) != null ? _ref3.call($(this), selection) : void 0 : void 0 : void 0;
      if (featureState !== void 0) {
        if (!$.isPlainObject(featureState)) {
          value = featureState;
          (featureState = {})[name] = value;
        }
        $.extend(state, featureState);
      }
    }
    return state;
  };
  updateState = function() {
    return setState.call(this, getState.call(this, document.activeElement !== this));
  };
  setState = function(state) {
    var data, delta, key, value, _ref;
    data = $(this).data('htmleditable');
    if ((_ref = data.state) == null) {
      data.state = {};
    }
    delta = {};
    for (key in state) {
      value = state[key];
      if (data.state[key] !== value) {
        data.state[key] = value;
        delta[key] = value;
      }
    }
    if (!$.isEmptyObject(delta)) {
      return $(this).trigger('state', delta);
    }
  };
  $rinsebin = $();
  getRinsebin = function() {
    if ($rinsebin.length !== 1) {
      $rinsebin = $('<div contenteditable="true" style="position: absolute; top: -100px; left: -100px; width: 1px; height: 1px; overflow: hidden;" />').prependTo('body');
    }
    return $rinsebin;
  };
  $.fn.htmleditable = $.pluginify({
    init: function(features) {
      var condition, feature, i, l, load, name, shouldBeIncluded, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3, _ref4, _ref5;
      if ($(this).closest(':htmleditable').length > 0 || $(this).parents('[contenteditable="true"]').length > 0) {
        return this;
      }
      rangy.init();
      features = $.merge(['base', 'multiline'], features != null ? features : []);
      load = $.merge([], features);
      for (_i = 0, _len = features.length; _i < _len; _i++) {
        feature = features[_i];
        _ref3 = (_ref = (_ref2 = $.htmleditable[feature]) != null ? _ref2.condition : void 0) != null ? _ref : [];
        for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
          condition = _ref3[_j];
          if (condition[0] === '-') {
            shouldBeIncluded = false;
            condition = condition.slice(1);
          } else {
            shouldBeIncluded = true;
          }
          if (__indexOf.call(load, condition) >= 0 !== shouldBeIncluded) {
            while (true) {
              i = $.inArray(feature, load);
              if (i === -1) {
                break;
              }
              load.splice(i, 1);
            }
            break;
          }
        }
      }
      features = {};
      for (_k = 0, _len3 = load.length; _k < _len3; _k++) {
        l = load[_k];
        features[l] = $.htmleditable[l];
      }
      $(this).data('htmleditable', {
        features: features
      }).attr('contenteditable', true).bind('paste', function(e) {
        var selection;
        selection = rangy.saveSelection();
        getRinsebin().focus();
        try {
          if (document.execCommand('Paste') !== false) {
            e.preventDefault();
          }
        } catch (err) {

        }
        return setTimeout(__bind(function() {
          var html;
          $(this).focus();
          rangy.restoreSelection(selection);
          html = getRinsebin().html();
          try {
            document.execCommand('insertHTML', void 0, html);
          } catch (err) {
            document.selection.createRange().pasteHTML(html);
          }
          return getRinsebin().empty();
        }, this));
      }).bind('focus', function() {
        try {
          return document.execCommand('styleWithCSS', void 0, false);
        } catch (err) {

        }
      }).bind('input', updateValue).bind('change mouseup focus blur', updateState).bind('keydown', function() {
        return setTimeout(__bind(function() {
          return updateState.call(this);
        }, this));
      });
      setState.call(this, getState.call(this, true));
      $(this).html(overriddenHtml.call($(this)));
      _ref4 = $(this).data('htmleditable').features;
      for (name in _ref4) {
        feature = _ref4[name];
        if (feature != null) {
          if ((_ref5 = feature.init) != null) {
            _ref5.call($(this));
          }
        }
      }
      return this;
    },
    value: function() {
      var _ref;
      return (_ref = $(this)).html.apply(_ref, arguments);
    },
    state: function(features) {
      var feature, requested, state, _i, _len, _ref;
      state = (_ref = $(this).data('htmleditable')) != null ? _ref.state : void 0;
      if (state == null) {
        return state;
      }
      if (typeof features === 'string') {
        return state[features];
      }
      if (!(features != null ? features.length : void 0)) {
        return $.extend({}, state);
      }
      requested = {};
      for (_i = 0, _len = features.length; _i < _len; _i++) {
        feature = features[_i];
        requested[feature] = state[feature];
      }
      return requested;
    },
    command: function() {
      var args, command, state, value, _ref, _ref2, _ref3;
      command = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      state = (_ref = $(this).data('htmleditable').features[command]) != null ? (_ref2 = _ref.context) != null ? (_ref3 = _ref2.set) != null ? _ref3.call.apply(_ref3, [$(this), $(this).htmleditable('selection')].concat(__slice.call(args))) : void 0 : void 0 : void 0;
      if (state != null) {
        if (!$.isPlainObject(state)) {
          value = state;
          state = {};
          state[command] = value;
        }
        setState.call(this, state);
      }
      updateValue.call(this);
      updateState.call(this);
      return this;
    },
    selection: function(range) {
      var intersection, r, scope, selection;
      rangy.init();
      if (arguments.length > 0) {
        if ((range != null ? range.nodeType : void 0) === 1) {
          r = rangy.createRange();
          r.selectNodeContents(range);
          range = r;
        }
        rangy.getSelection().setSingleRange(range);
        updateState.call(this);
        return this;
      }
      selection = rangy.getSelection();
      if (selection.rangeCount !== 1) {
        return;
      }
      range = selection.getRangeAt(0);
      scope = rangy.createRange();
      scope.selectNodeContents(this);
      intersection = scope.intersection(range);
      if (intersection === null || !intersection.equals(range)) {
        return;
      }
      return range;
    }
  });
  if ((_ref = $.htmleditable) == null) {
    $.htmleditable = {};
  }
  $.fn.domSplice = function(element) {
    var elements;
    elements = [];
    this.each(function() {
      var $element, _ref2;
      if (element) {
        $element = $(element);
        elements.push.apply(elements, $element.get());
      }
      if (this.nodeType === 3 && ((_ref2 = this.nodeName.toLowerCase()) === 'style')) {
        if (element) {
          return $(this).replaceWith($element);
        } else {
          return $(this).remove();
        }
      } else if (element) {
        $element.insertBefore(this).prepend($(this).contents());
        return $(this).remove();
      } else {
        return $(this).replaceWith($(this).contents());
      }
    });
    return $(elements);
  };
}).call(this);
