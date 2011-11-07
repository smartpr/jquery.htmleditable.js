(function() {
  var $elem;
  $elem = void 0;
  beforeEach(function() {
    return $elem = $('#editable', fix);
  });
  describe("$.htmleditable.linebreaks", function() {
    it("adds trailing linebreaks to paragraph elements", function() {
      $elem.htmleditable().htmleditable('value', "<p>paragraph</p>text");
      return expect($elem.htmleditable('value').toLowerCase()).toBe("paragraph<br><br>text");
    });
    it("adds trailing linebreaks to header elements", function() {
      $elem.htmleditable().htmleditable('value', "<h1>header<br></h1>text");
      return expect($elem.htmleditable('value').toLowerCase()).toBe("header<br><br><br>text");
    });
    return it("ignores namespaced elements", function() {
      $elem.htmleditable().htmleditable('value', 'text<o:p></o:p>');
      return expect($elem.htmleditable('value').toLowerCase()).toBe('text');
    });
  });
}).call(this);
