(function() {
  var $;

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
      var _this = this;
      $('head').append("<style>			#" + (this.prop('id')) + ".no-margins p, #" + (this.prop('id')) + ".no-margins ul, #" + (this.prop('id')) + ".no-margins ol {				margin-top: 0;				margin-bottom: 0;			}		</style>");
      return this.bind('state', function(e, state) {
        if ('margins' in state) {
          return _this["" + (state.margins === true ? 'remove' : 'add') + "Class"]('no-margins');
        }
      });
    },
    content: true,
    state: function() {
      var _ref;
      return (_ref = this.htmleditable('state', 'margins')) != null ? _ref : false;
    }
  };

}).call(this);
