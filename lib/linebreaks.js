(function() {
  var $;
  $ = jQuery;
  $.htmleditable.linebreaks = {
    element: function(element) {
      var _ref, _ref2, _ref3;
      if (this.length === 0 || (element != null)) {
        return;
      }
      if (this.is('br')) {
        return document.createElement('br');
      }
      if (this.is('p, :header') && ((_ref = (_ref2 = this.prop('prefix')) != null ? _ref2 : this.prop('scopeName')) === void 0 || _ref === null || _ref === 'HTML')) {
        return function(element, children) {
          if (element != null) {
            return;
          }
          children.appendChild(document.createElement('br'));
          children.appendChild(document.createElement('br'));
        };
      }
      if ((_ref3 = this.css('display')) === 'block' || _ref3 === 'list-item' || _ref3 === 'table-row') {
        return function(element, children) {
          var last;
          if (element != null) {
            return;
          }
          last = children.lastChild;
          while ((last != null) && last.nodeType === 3 && /^\s*$/.test(last.data)) {
            last = last.previousSibling;
          }
          if (!$(last).is('br')) {
            children.appendChild(document.createElement('br'));
          }
        };
      }
    },
    init: function() {
      return $('head').append("<style>			#" + (this.prop('id')) + " p {				margin-top: 0;				margin-bottom: 0;			}		</style>");
    },
    change: function() {
      var sel;
      if ($(this).find('div, p').length > 0) {
        sel = rangy.saveSelection();
        $(this).find('div').each(function() {
          var prev;
          prev = $(this)[0].previousSibling;
          if ((prev != null) && !$(prev).is('br')) {
            $(this).before('<br>');
          }
          return $(this).domSplice();
        });
        $(this).find('p').each(function() {
          var _ref;
          if (!(((_ref = $(this)[0].previousSibling) != null ? _ref.nodeType : void 0) === 1 && $(this).prev().is('br'))) {
            $(this).after('<br>');
          }
          return $(this).domSplice();
        });
        return rangy.restoreSelection(sel);
      }
    }
  };
}).call(this);
