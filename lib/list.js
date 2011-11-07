(function() {
  var $;
  $ = jQuery;
  $.htmleditable.list = {
    element: function(element, children) {
      var $child, child, list, name, next, _i, _len, _ref, _ref2, _ref3;
      if (!this.is('ul, ol')) {
        list = document.createElement('ul');
        child = children.firstChild;
        while (child != null) {
          $child = $(child);
          next = child.nextSibling;
          if ($child.is('li')) {
            if (!list.hasChildNodes()) {
              children.insertBefore(list, child);
            }
            list.appendChild(child);
            $child.html($child.html().replace(/^\S\.?(?:&nbsp;)+([\s\S]+)$/, "$1"));
          } else if (list.hasChildNodes()) {
            if (child.nodeType === 3 && /^\s*$/.test(child.data)) {
              children.removeChild(child);
            } else {
              list = document.createElement('ul');
            }
          }
          child = next;
        }
      }
      if (this.length === 0) {
        return;
      }
      _ref3 = (_ref = (_ref2 = this.attr('class')) != null ? _ref2.split(' ') : void 0) != null ? _ref : [];
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        name = _ref3[_i];
        if (/^MsoListParagraph\S*$/.test(name)) {
          return document.createElement('li');
        }
      }
      if (element != null) {
        return;
      }
      if (this.is('ul, ol, li')) {
        return document.createElement(this.prop('nodeName'));
      }
    },
    state: function() {
      if ($(this).htmleditable('selection') == null) {
        return null;
      }
      return {
        orderedList: document.queryCommandState('insertOrderedList'),
        unorderedList: document.queryCommandState('insertUnorderedList')
      };
    },
    command: function(ordered) {
      return document.execCommand("insert" + (ordered ? 'Ordered' : 'Unordered') + "List");
    }
  };
}).call(this);
