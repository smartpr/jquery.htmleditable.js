(function() {
  /**
  
  * Defined in `$.htmleditable.multiline`.
  * Will not be loaded if [singleline](#docs.features.singleline) is enabled.
  * Allows `p`, `div` and `br`.
  
  This feature makes sure that new lines can be created. It is enabled by default
  because we need either multiline or singleline support, and multiline is the
  most sensible default.
  
  */
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
