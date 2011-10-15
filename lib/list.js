(function() {
  var $;
  $ = jQuery;
  $.htmleditable.list = {
    condition: ['multiline'],
    allow: function(attrs) {
      var value, _i, _len, _ref, _ref2, _ref3, _ref4;
      if (this.is('ul, ol, li')) {
        return true;
      }
      _ref4 = (_ref = attrs != null ? (_ref2 = attrs["class"]) != null ? (_ref3 = _ref2.value) != null ? _ref3.split(' ') : void 0 : void 0 : void 0) != null ? _ref : [];
      for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
        value = _ref4[_i];
        if (/^MsoListParagraph\S*$/.test(value)) {
          return function(element) {
            var $element;
            $element = $(element).wrap('<li />').parent();
            if ($element.prev().is('ul')) {
              $element.appendTo($element.prev());
            } else {
              $element.wrap('<ul />');
            }
            return true;
          };
        }
      }
    },
    context: {
      get: function() {
        return {
          orderedList: document.queryCommandState('insertOrderedList'),
          unorderedList: document.queryCommandState('insertUnorderedList')
        };
      },
      set: function(selection, ordered) {
        return document.execCommand("insert" + (ordered ? 'Ordered' : 'Unordered') + "List");
      }
    }
  };
}).call(this);
