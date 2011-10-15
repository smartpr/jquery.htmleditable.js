(function() {
  var $;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $ = jQuery;
  $.htmleditable.margins = {
    condition: ['multiline'],
    output: function($tree) {
      if (!this.htmleditable('state', 'margins')) {
        return $tree.find('p, ul, ol').css({
          'margin-top': 0,
          'margin-bottom': 0
        });
      }
    },
    init: function() {
      $('head').append("<style type=\"text/css\">			#" + (this.prop('id')) + ".no-margins p, #" + (this.prop('id')) + ".no-margins ul, #" + (this.prop('id')) + ".no-margins ol {				margin-top: 0;				margin-bottom: 0;			}		</style>");
      this.bind('state', __bind(function(e, state) {
        if ('margins' in state) {
          return this["" + (state.margins === true ? 'remove' : 'add') + "Class"]('no-margins');
        }
      }, this));
      if (this.htmleditable('state', 'margins') === null) {
        return this.htmleditable('command', 'margins', false);
      }
    },
    content: true,
    context: {
      set: function(selection, margins) {
        return margins != null ? margins : !this.htmleditable('state', 'margins');
      }
    }
  };
}).call(this);
