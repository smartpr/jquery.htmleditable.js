(function() {
  var $elem;
  $elem = void 0;
  beforeEach(function() {
    return $elem = $('#editable', fix);
  });
  describe("$.htmleditable.link", function() {
    return xit("updates link target according to link text change if text is target", function() {
      var $link;
      $elem.htmleditable(['link']).htmleditable('value', 'This is a link: <a href="http://smart.pr/">http://smart.pr/</a> and this is not');
      ($link = $elem.find('a')).html("" + ($link.html()) + "#aboutus");
      expect($link.attr('href')).toBe($link.html());
      return expect($elem.htmleditable('value')).toBe('This is a link: <a href="http://smart.pr/#aboutus">http://smart.pr/#aboutus</a> and this is not');
    });
  });
}).call(this);
