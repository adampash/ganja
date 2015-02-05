(function() {
  this.config = {
    dev: true,
    socializer_url: function() {
      if (this.dev) {
        return "http://localhost:3000";
      } else {
        return "http://gawker-socializer.herokuapp.com";
      }
    },
    whos_editing_url: function() {
      if (this.dev) {
        return "http://localhost:3001";
      } else {
        return "tbd";
      }
    }
  };

}).call(this);

//# sourceMappingURL=config.js.map
