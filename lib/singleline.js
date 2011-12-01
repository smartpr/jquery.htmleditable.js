(function() {
  var $;

  $ = jQuery;

  $.htmleditable.singleline = {
    condition: ['-multiline'],
    init: function() {
      return this.bind('keydown', 'return', function(e) {
        return e.preventDefault();
      });
    }
  };

}).call(this);
