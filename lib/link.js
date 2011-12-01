(function() {
  var $;

  $ = jQuery;

  $.htmleditable.link = {
    element: function(element) {
      var link;
      if (this.length === 0 || (element != null)) return;
      if (this.is('a[href^="http://"]')) {
        link = document.createElement('a');
        link.setAttribute('href', this.attr('href'));
        return link;
      }
    },
    init: function() {},
    state: function() {
      var selection;
      selection = $(this).htmleditable('selection');
      if (selection == null) return null;
      return $(selection.collapsed ? selection.commonAncestorContainer : selection.getNodes()).closest('a').get();
    },
    command: function(url) {
      var selection;
      selection = $(this).htmleditable('selection');
      if (selection == null) return;
      if (url == null) url = 'http://';
      if (!selection.collapsed) {
        return document.execCommand('createLink', null, url);
      } else {
        try {
          return document.execCommand('insertHTML', null, "<a href=\"" + url + "\">" + url + "</a>");
        } catch (err) {

        }
      }
    }
  };

}).call(this);
