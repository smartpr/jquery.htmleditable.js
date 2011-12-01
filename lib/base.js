(function() {

  /**
  
  Is defined in `$.htmleditable.base` and does some generic cleaning. Is enabled
  by default. You usually wouldn't have to deal with this one.
  */

  var $;

  $ = jQuery;

  $.htmleditable.base = {
    input: function(html) {
      return html.replace(/Version:[\d.]+\nStartHTML:\d+\nEndHTML:\d+\nStartFragment:\d+\nEndFragment:\d+/gi, '');
    }
  };

}).call(this);
