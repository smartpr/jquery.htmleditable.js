(function() {
  var $;
  var __slice = Array.prototype.slice;
  $ = jQuery;
  $.pluginify = function(actions) {
    return function() {
      var a, action, args, defaultAction, result, useDefault;
      action = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      defaultAction = void 0;
      useDefault = true;
      for (a in actions) {
                if (defaultAction != null) {
          defaultAction;
        } else {
          defaultAction = a;
        };
        useDefault = action !== a;
        if (!useDefault) {
          break;
        }
      }
      if (useDefault) {
        args.unshift(action);
        action = defaultAction;
      }
      result = this;
      this.each(function() {
        var value, _ref;
        if ((value = (_ref = actions[action]) != null ? _ref.apply(this, args) : void 0) !== this) {
          result = value;
        }
        return result !== value;
      });
      return result;
    };
  };
}).call(this);
