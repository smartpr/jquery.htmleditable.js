(function() {
  var $;

  $ = jQuery;

  $.htmleditable["native"] = {
    element: function(element) {
      var _ref;
      if (element != null) return;
      if (this.is('p, div, br') && ((_ref = this.prop('scopeName')) === (void 0) || _ref === 'HTML')) {
        return document.createElement(this[0].nodeName);
      }
      if (this.is(':header')) {
        return function(element) {
          if (element != null) return;
          return document.createElement('p');
        };
      }
    }
  };

}).call(this);
