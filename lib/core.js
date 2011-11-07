(function() {
  'use strict';
  var $, $rinsebin, cleanTree, getRinsebin, _ref;
  var __slice = Array.prototype.slice, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $ = jQuery.sub();
  jQuery.expr[':'].htmleditable = function(el) {
    var $el;
    $el = $(el);
    return $el.is('[contenteditable="true"]') && ($el.data('htmleditable') != null);
  };
  $.fn.originalHtml = $.fn.html;
  jQuery.fn.html = function() {
    var _ref;
    if (this.eq(0).is(':htmleditable')) {
      return this.htmleditable.apply(this, ['value'].concat(__slice.call(arguments)));
    }
    return (_ref = $(this)).originalHtml.apply(_ref, arguments);
  };
  jQuery.fn.htmleditable = $.pluginify({
    init: function(linemode, features) {
      var args, condition, feature, i, keys, l, load, name, shouldBeIncluded, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3, _ref4, _ref5, _ref6;
      if (!jQuery.isReady) {
        $.error("Initialization of htmleditable is not possible before the document is ready. Have you placed your code in a 'ready' handler?");
      }
      if ($(this).closest(':htmleditable').length > 0 || $(this).parents('[contenteditable="true"]').length > 0) {
        return this;
      }
      rangy.init();
      features = $.merge([linemode, 'base'], features != null ? features : []);
      load = $.merge([], features);
      for (_i = 0, _len = features.length; _i < _len; _i++) {
        feature = features[_i];
        _ref3 = (_ref = (_ref2 = jQuery.htmleditable[feature]) != null ? _ref2.condition : void 0) != null ? _ref : [];
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
        features[l] = jQuery.htmleditable[l];
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
          var cleaned, html;
          $(this).focus();
          console.log(getRinsebin().html());
          cleaned = cleanTree.call($(this), getRinsebin()[0]);
          getRinsebin().empty().append(cleaned);
          html = getRinsebin().html();
          getRinsebin().empty();
          rangy.restoreSelection(selection);
          try {
            return document.execCommand('insertHTML', void 0, html);
          } catch (err) {
            return document.selection.createRange().pasteHTML(html);
          }
        }, this));
      }).bind('input', function() {
        return $(this).updateValue();
      }).bind('change mouseup touchend focus blur', function() {
        return $(this).updateState();
      }).bind('keydown', function() {
        return setTimeout(__bind(function() {
          return $(this).updateState();
        }, this));
      });
      try {
        document.execCommand('styleWithCSS', void 0, false);
      } catch (err) {

      }
      $(this).updateState();
      $(this).htmleditable('value', $(this).originalHtml());
      _ref4 = $(this).data('htmleditable').features;
      for (name in _ref4) {
        feature = _ref4[name];
        if ((_ref5 = feature.init) != null) {
          _ref5.call($(this));
        }
        _ref6 = feature.hotkeys;
        for (keys in _ref6) {
          args = _ref6[keys];
          $(this).bind('keydown', keys, function(e) {
            var _ref7;
            e.preventDefault();
            e.stopPropagation();
            return (_ref7 = $(this)).htmleditable.apply(_ref7, ['command', name].concat(__slice.call(args)));
          });
        }
      }
      return this;
    },
    value: function(html) {
      var cleaned, result;
      if (html == null) {
        return $(this).data('htmleditable').value;
      }
      html = html.replace(/^([\s\S]*)<!--htmleditable:state\s([\s\S]*?)-->([\s\S]*)$/g, __bind(function(match, before, settings, after) {
        var features, name, value, _ref, _ref2;
        features = $(this).data('htmleditable').features;
        _ref = $.parseJSON("{ " + settings + " }");
        for (name in _ref) {
          value = _ref[name];
          if (((_ref2 = features[name]) != null ? _ref2.content : void 0) === true) {
            $(this).htmleditable('command', name, value);
          }
        }
        return before + after;
      }, this));
      getRinsebin().html(html);
      cleaned = cleanTree.call($(this), getRinsebin()[0]);
      getRinsebin().empty();
      result = $(this).empty().append(cleaned);
      $(this).updateValue();
      return result;
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
      var args, command, feature, state, _ref;
      command = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      state = {};
      feature = $(this).data('htmleditable').features[command];
      if ('command' in feature) {
        (_ref = feature.command).call.apply(_ref, [$(this)].concat(__slice.call(args)));
      } else {
        state[command] = args[0];
      }
      $(this).updateState(state);
      $(this).updateValue();
      return this;
    },
    selection: function(range) {
      var intersection, r, scope, selection;
      if (arguments.length > 0) {
        if ((range != null ? range.nodeType : void 0) === 1) {
          r = rangy.createRange();
          r.selectNodeContents(range);
          range = r;
        }
        rangy.getSelection().setSingleRange(range);
        $(this).updateState();
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
  if ((_ref = jQuery.htmleditable) == null) {
    jQuery.htmleditable = {};
  }
  cleanTree = function(root) {
    var features, layer;
    features = this.data('htmleditable').features;
    layer = function(node) {
      var $node, child, children, element, feature, i, include, name, processor, processors, result, _i, _len, _ref2;
      $node = node === root ? $() : $(node);
      if (node.nodeType === 1) {
        children = document.createDocumentFragment();
        _ref2 = node.childNodes;
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          child = _ref2[_i];
          include = layer.call(this, child);
          if (include != null) {
            children.appendChild(include);
          }
        }
        processors = (function() {
          var _results;
          _results = [];
          for (name in features) {
            feature = features[name];
            _results.push(feature.element);
          }
          return _results;
        })();
        i = 0;
        element = void 0;
        while (i < processors.length) {
          processor = processors[i++];
          result = processor != null ? processor.call($node, element, children) : void 0;
          if ($.isFunction(result)) {
            processors.push(result);
          } else if (result != null) {
            element = result;
          }
        }
        if (element != null) {
          if (children.hasChildNodes()) {
            element.appendChild(children);
          }
          children = element;
        }
        return children;
      } else if (node.nodeType === 3) {
        return $node.clone(false, false)[0];
      }
    };
    return layer.call(this, root);
  };
  $.fn.updateValue = function() {
    var $current, current, data, feature, name, settings, _ref2, _ref3, _ref4, _ref5;
    data = this.data('htmleditable');
    _ref2 = data.features;
    for (name in _ref2) {
      feature = _ref2[name];
      if ((_ref3 = feature.change) != null) {
        _ref3.call(this);
      }
    }
    $current = this.clone(false, false);
    settings = {};
    _ref4 = data.features;
    for (name in _ref4) {
      feature = _ref4[name];
      if ((_ref5 = feature.output) != null) {
        _ref5.call(this, $current);
      }
      if (feature.content === true) {
        settings[name] = this.htmleditable('state', name);
      }
    }
    current = $current.html();
    if (!$.isEmptyObject(settings)) {
      settings = JSON.stringify(settings);
      current = "<!--htmleditable:state " + settings.slice(1, settings.length - 1) + " -->" + current;
    }
    if (data.value !== current) {
      data.value = current;
      return this.change();
    }
  };
  $.fn.updateState = function(state) {
    var data, delta, feature, featureState, featuresState, key, name, selection, value, _ref2, _ref3, _ref4;
    selection = this.htmleditable('selection');
    featuresState = {};
    _ref2 = this.data('htmleditable').features;
    for (name in _ref2) {
      feature = _ref2[name];
      featureState = feature != null ? (_ref3 = feature.state) != null ? _ref3.call(this) : void 0 : void 0;
      if (featureState !== void 0) {
        if (!$.isPlainObject(featureState)) {
          value = featureState;
          (featureState = {})[name] = value;
        }
        $.extend(featuresState, featureState);
      }
    }
    $.extend(featuresState, state);
    data = this.data('htmleditable');
    if ((_ref4 = data.state) == null) {
      data.state = {};
    }
    delta = {};
    for (key in featuresState) {
      value = featuresState[key];
      if (data.state[key] !== value) {
        data.state[key] = value;
        delta[key] = value;
      }
    }
    if (!$.isEmptyObject(delta)) {
      return this.trigger('state', delta);
    }
  };
  $rinsebin = $();
  getRinsebin = function() {
    if ($rinsebin.length !== 1) {
      $rinsebin = $('<div contenteditable="true" tabindex="-1" style="position: absolute; top: -100px; left: -100px; width: 1px; height: 1px; overflow: hidden;" />').prependTo('body');
    }
    return $rinsebin;
  };
  jQuery.fn.domSplice = function(element) {
    var elements;
    elements = [];
    this.each(function() {
      var $element, _ref2;
      if (element) {
        $element = $(element);
        elements.push.apply(elements, $element.get());
      }
      if (this.nodeType === 1 && ((_ref2 = this.nodeName.toLowerCase()) === 'style' || _ref2 === 'script' || _ref2 === 'iframe')) {
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
