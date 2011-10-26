(function() {
  var $, $testbed, getTestbed, tag;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $ = jQuery;
  tag = 'b';
  $testbed = $();
  getTestbed = function() {
    if ($testbed.length !== 1) {
      $testbed = $('<div contenteditable="true" style="position: absolute; top: -100px; left: -100px; width: 1px; height: 1px; overflow: hidden;">text</div>').prependTo('body');
    }
    return $testbed;
  };
  $(function() {
    var range;
    $testbed = getTestbed();
    rangy.init();
    range = rangy.createRange();
    range.selectNodeContents($testbed[0]);
    rangy.getSelection().setSingleRange(range);
    $testbed.focus();
    document.execCommand('bold', null, null);
    tag = $testbed.children()[0].nodeName;
    return $testbed.remove();
  });
  $.htmleditable.bold = {
    allow: function() {
      if (this.is(tag)) {
        return true;
      }
      if (this.is('strong')) {
        return document.createElement(tag);
      }
      if (this.is(':header')) {
        return function(element, remove) {
          if (remove) {
            return $(element).contents().wrapAll("<" + tag + " />");
          }
        };
      }
    },
    output: function($tree) {
      return $tree.find(tag).domSplice('<strong />');
    },
    init: function() {
      return this.bind('keydown', 'ctrl+b meta+b', __bind(function(e) {
        e.preventDefault();
        e.stopPropagation();
        return this.htmleditable('command', 'bold');
      }, this));
    },
    context: {
      get: function(selection) {
        if (selection == null) {
          return null;
        }
        return document.queryCommandState('bold');
      },
      set: function() {
        document.execCommand('bold', null, null);
      }
    }
  };
}).call(this);
