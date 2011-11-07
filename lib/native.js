(function() {
  var $;
  $ = jQuery;
  $.htmleditable.multiline = {
    condition: ['-singleline'],
    allow: function() {
      if (this.is('p, div, br')) {
        return true;
      }
      if (this.is(':header')) {
        return function(element, remove) {
          if (remove) {
            return $(element).wrap('<p />');
          }
        };
      }
    },
    init: function() {}
  };
}).call(this);
