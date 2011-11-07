(function() {
  var $elem;
  $elem = void 0;
  beforeEach(function() {
    return $elem = $('#editable', fix);
  });
  describe("$.htmleditable.margins", function() {
    return xit("can be initialized", function() {
      spyOn($.htmleditable.margins, 'init');
      $elem.htmleditable(['margins']);
      return expect($.htmleditable.margins.init).toHaveBeenCalled();
    });
  });
}).call(this);
