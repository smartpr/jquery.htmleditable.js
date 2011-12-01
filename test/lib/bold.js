(function() {
  var $elem;

  $elem = void 0;

  beforeEach(function() {
    return $elem = $('#editable', fix);
  });

  describe("$.htmleditable.bold", function() {
    describe("interprets headers", function() {
      it("makes headers bold", function() {
        $elem.htmleditable(['bold']).htmleditable('value', "<h1>bold</h1>not bold");
        return expect($elem.htmleditable('value').toLowerCase()).toBe("<p><strong>bold</strong></p>not bold");
      });
      it("keeps trailing whitespace and linebreaks outside of the bold", function() {
        $elem.htmleditable(['bold']).htmleditable('value', "<h1>bold<br></h1>not bold");
        return expect($elem.htmleditable('value').toLowerCase()).toBe("<strong>bold</strong><br><br><br>not bold");
      });
      it("does not add element if header already contains bold tag", function() {
        $elem.htmleditable(['bold']).htmleditable('value', "<h1><strong>bold</strong></h1>not bold");
        return expect($elem.htmleditable('value').toLowerCase()).toBe("<strong>bold</strong><br><br>not bold");
      });
      return it("does not add element if header is wrapped by bold tag", function() {
        $elem.htmleditable(['bold']).htmleditable('value', "<strong><h1>bold</h1></strong>not bold");
        return expect($elem.htmleditable('value').toLowerCase()).toBe("<p><strong>bold</strong><p>not bold");
      });
    });
    return it("defines hotkeys", function() {
      spyOn($.htmleditable.bold, 'command');
      $elem.htmleditable(['bold']);
      $elem.trigger({
        type: 'keydown',
        target: $elem[0],
        which: 66,
        altKey: false,
        ctrlKey: false,
        metaKey: false,
        shiftKey: false
      });
      $elem.trigger({
        type: 'keydown',
        target: $elem[0],
        which: 66,
        altKey: false,
        ctrlKey: true,
        metaKey: false,
        shiftKey: false
      });
      $elem.trigger({
        type: 'keydown',
        target: $elem[0],
        which: 66,
        altKey: false,
        ctrlKey: false,
        metaKey: true,
        shiftKey: false
      });
      return expect($.htmleditable.bold.command.callCount).toBe(2);
    });
  });

}).call(this);
