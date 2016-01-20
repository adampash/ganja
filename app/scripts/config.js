(function() {
  this.config = {
    dev: false,
    socializer_url: function() {
      if (this.dev) {
        return "http://localhost:3000";
      } else {
        return "https://gawker-socializer.herokuapp.com";
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
