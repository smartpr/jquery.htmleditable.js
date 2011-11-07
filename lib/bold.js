(function() {
  var $, name, tag;
  $ = jQuery;
  name = void 0;
  tag = function() {
    var $testbed, range;
    if (name != null) {
      return name;
    }
    $testbed = $('<div contenteditable="true" tabindex="-1" style="position: absolute; top: -100px; left: -100px; width: 1px; height: 1px; overflow: hidden;">text</div>').prependTo('body');
    range = rangy.createRange();
    range.selectNodeContents($testbed[0]);
    rangy.getSelection().setSingleRange(range);
    document.execCommand('bold', null, null);
    name = $testbed.children()[0].nodeName;
    $testbed.remove();
    return name != null ? name : 'b';
  };
  $.htmleditable.bold = {
    element: function(element) {
      if (this.length === 0 || (element != null)) {
        return;
      }
      if (this.is('strong, b')) {
        return document.createElement(tag());
      }
      if (this.is(':header')) {
        return function(element, children) {
          var bold;
          if (element != null) {
            return;
          }
          bold = document.createElement(tag());
          while (children.firstChild != null) {
            bold.appendChild(children.firstChild);
          }
          children.appendChild(bold);
        };
      }
    },
    output: function($tree) {
      return $tree.find(tag()).domSplice('<strong />');
    },
    state: function() {
      if ($(this).htmleditable('selection') == null) {
        return null;
      }
      return document.queryCommandState('bold');
    },
    hotkeys: {
      'ctrl+b meta+b': []
    },
    command: function() {
      return document.execCommand('bold', null, null);
    }
  };
}).call(this);
