(function() {
  var $elem;

  $elem = void 0;

  beforeEach(function() {
    return $elem = $('#editable', fix);
  });

  describe("$.htmleditable.multiline", function() {
    it("is enabled (and thus initialized) by default", function() {
      spyOn($.htmleditable.multiline, 'init');
      $elem.htmleditable();
      return expect($.htmleditable.multiline.init).toHaveBeenCalled();
    });
    it("only allows p, div & br elements", function() {
      $elem.htmleditable().htmleditable('value', "<div>a<p>b</p>c<br /><strong>not bold</strong></div>");
      return expect($elem.htmleditable('value'), "<div>a<p>b</p>c<br />not bold</div>");
    });
    return it("transforms :header elements into p elements", function() {
      $elem.htmleditable().htmleditable('value', "<h1>a</h1><h2>b<h2>");
      return expect($elem.htmleditable('value'), "<p>a</p><p>b</p>");
    });
  });

}).call(this);
