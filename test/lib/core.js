(function() {
  var $elem;
  $elem = void 0;
  beforeEach(function() {
    return $elem = $('#editable', fix);
  });
  afterEach(function() {
    return waits(0);
  });
  describe("$.fn.htmleditable()", function() {
    describe("init", function() {
      it("explicitly", function() {
        expect($elem.htmleditable('init').get()).toEqual($elem.get());
        return expect($elem).toBe(':htmleditable');
      });
      return it("implicitly", function() {
        expect($elem.htmleditable().get()).toEqual($elem.get());
        return expect($elem).toBe(':htmleditable');
      });
    });
    describe("value", function() {
      it("gets clean content", function() {
        return expect($.trim($elem.htmleditable().htmleditable('value'))).toBe("Initial content!");
      });
      return it("sets clean content", function() {
        $elem.htmleditable().htmleditable('value', 'Scrutiny is <strong>strong</strong>!');
        return expect($.trim($elem[0].innerHTML)).toBe('Scrutiny is strong!');
      });
    });
    describe("selection", function() {
      it("returns undefined if no focus or selection has been set", function() {
        $elem.htmleditable();
        return expect($elem.htmleditable('selection')).toBeUndefined();
      });
      it("returns undefined if selection is not (entirely) contained by the editable field", function() {
        var range;
        $elem.htmleditable();
        range = rangy.createRange();
        range.setStart($('#before-editable', fix).contents()[0], 3);
        range.setEnd($('#uneditable', fix).contents()[0], 5);
        rangy.getSelection().setSingleRange(range);
        return expect($elem.htmleditable('selection')).toBeUndefined();
      });
      it("returns a Rangy range object if selection exists", function() {
        var range, selection;
        $elem.htmleditable();
        range = rangy.createRange();
        range.selectNodeContents($elem[0]);
        rangy.getSelection().setSingleRange(range);
        selection = $elem.htmleditable('selection');
        expect(selection instanceof rangy.WrappedRange).toBe(true);
        return expect(selection.toString()).toBe('Initial content!');
      });
      it("sets the selection given a Rangy range object", function() {
        var range;
        $elem.htmleditable();
        range = rangy.createRange();
        range.selectNodeContents($elem[0]);
        $elem.htmleditable('selection', range);
        return expect($elem.htmleditable('selection').toString()).toBe('Initial content!');
      });
      return it("sets the selection given a DOM node", function() {
        $elem.htmleditable();
        $elem.htmleditable('selection', $elem[0]);
        return expect($elem.htmleditable('selection').toString()).toBe('Initial content!');
      });
    });
    describe("state", function() {
      it("gets a specific state", function() {
        $elem.htmleditable(['bold']).htmleditable('selection', $elem[0]);
        expect($elem.htmleditable('state', 'bold')).toBe(false);
        $elem.htmleditable('selection', $elem.find('strong, b')[0]);
        return expect($elem.htmleditable('state', 'bold')).toBe(true);
      });
      it("gets a selection of states", function() {
        $elem.htmleditable(['bold', 'link']).htmleditable('selection', $elem[0]);
        return expect($elem.htmleditable('state', ['bold'])).toEqual({
          bold: false
        });
      });
      it("gets the full state", function() {
        $elem.htmleditable(['bold', 'link']).htmleditable('selection', $elem[0]);
        return expect($elem.htmleditable('state')).toEqual({
          bold: false,
          link: []
        });
      });
      it("returns null for disabled states", function() {
        $elem.htmleditable(['bold']);
        return expect($elem.htmleditable('state', 'bold')).toBeNull();
      });
      return it("updates on keydown, reflecting the state that takes effect only after its handlers executed", function() {
        runs(function() {
          var range;
          $elem.htmleditable(['bold']).focus().trigger('keydown');
          range = rangy.createRange();
          range.setStart($elem.find('strong, b').contents()[0], 1);
          range.setEnd(range.startContainer, range.startOffset);
          return rangy.getSelection().setSingleRange(range);
        });
        waits(0);
        return runs(function() {
          return expect($elem.htmleditable('state', 'bold')).toBe(true);
        });
      });
    });
    return describe("command", function() {
      return it("invokes a feature command", function() {
        $elem.htmleditable(['bold']).htmleditable('selection', $elem.find('strong, b')[0]).htmleditable('command', 'bold');
        return expect($elem.htmleditable('state', 'bold')).toBe(false);
      });
    });
  });
  describe("events", function() {
    it("triggers change upon value change", function() {
      var handler;
      $elem.bind('change', handler = jasmine.createSpy()).htmleditable();
      $elem.htmleditable('value', "Changed content");
      return expect(handler).toHaveBeenCalled();
    });
    it("triggers state upon initialization", function() {
      var handler;
      $elem.bind('state', handler = jasmine.createSpy()).htmleditable(['bold', 'link']);
      return expect(handler.mostRecentCall.args[1]).toEqual({
        bold: null,
        link: null
      });
    });
    return it("triggers state upon state change", function() {
      var handler;
      $elem.bind('state', handler = jasmine.createSpy()).htmleditable(['bold']);
      $elem.htmleditable('selection', $elem.find('strong, b')[0]);
      return expect(handler.mostRecentCall.args[1]).toEqual({
        bold: true
      });
    });
  });
  xdescribe("$.fn.html() & $.fn.val()", function() {
    it("gets like $.fn.htmleditable('value')", function() {
      $elem.htmleditable();
      expect($elem.html()).toBe($elem.htmleditable('value'));
      return expect($elem.val()).toBe($elem.htmleditable('value'));
    });
    return it("sets like $.fn.htmleditable('value')", function() {
      $elem.htmleditable();
      expect($elem.html('Scrutiny is <strong>strong</strong>!').html()).toBe('Scrutiny is strong!');
      return expect($elem.val('Strong is the <strong>scrutiny</strong>!').val()).toBe('Strong is the scrutiny!');
    });
  });
  describe(":htmleditable", function() {
    it("does not match regular contenteditables", function() {
      return expect($('[contenteditable="true"]', fix)).not.toBe(':htmleditable');
    });
    return it("matches htmleditables", function() {
      return expect($elem.htmleditable()).toBe(':htmleditable');
    });
  });
}).call(this);
