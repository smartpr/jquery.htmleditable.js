(function() {
  var $;
  $ = jQuery;
  $.htmleditable.link = {
    allow: function(attrs) {
      if (this.is('a') && (attrs != null ? attrs.href.value : void 0)) {
        this.attr('href', attrs.href.value);
        return true;
      }
    },
    init: function() {
      return this.bind('DOMCharacterDataModified', function(e) {
        var $target;
        $target = $(e.target);
        if ($target.is('a') && e.originalEvent.prevValue === $target.attr('href')) {
          $target.attr('href', e.originalEvent.newValue);
          return updateValue.call(this);
        }
      });
    },
    context: {
      get: function(selection) {
        if (selection == null) {
          return null;
        }
        return $(selection.collapsed ? selection.commonAncestorContainer : selection.getNodes()).closest('a').get();
      },
      set: function(selection, url) {
        var state;
        state = $(this).htmleditable('state', 'link');
        if (!((state != null) && state.length === 0)) {
          return;
        }
        if (url == null) {
          url = 'http://';
        }
        if (!selection.collapsed) {
          document.execCommand('createLink', null, url);
        } else {
          try {
            document.execCommand('insertHTML', null, "<a href=\"" + url + "\">" + url + "</a>");
          } catch (err) {

          }
        }
      }
    }
  };
}).call(this);
