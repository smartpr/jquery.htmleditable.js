(function() {
  var $elem;
  $elem = void 0;
  beforeEach(function() {
    return $elem = $('#editable', fix);
  });
  describe("$.htmleditable.bold", function() {
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
