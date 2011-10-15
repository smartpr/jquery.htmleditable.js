(function() {
  beforeEach(function() {
    return this.addMatchers({
      toStartWith: function(expected) {
        return this.actual.indexOf(expected) === 0;
      },
      toEndWith: function(expected) {
        return this.actual.slice(this.actual.length - expected.length) === expected;
      },
      toBeFlattened: function(expected) {
        return this.actual.replace(/^\s+/, '').replace(/\s+$/, '').replace(/\s+/g, ' ') === expected;
      }
    });
  });
}).call(this);
