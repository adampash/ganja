(function() {
  var check, editing, interval, view;

  check = {
    editorVisible: function() {
      return $('div.editor:visible').length !== 0;
    },
    countdown: function() {
      return 140 - 24 - $('#tweet-box').val().length;
    },
    getBlogs: function() {
      var blogs, index, sites, url, urls, yourBlogs, _i, _len, _results;
      console.log('getting blogs');
      urls = [];
      sites = [];
      yourBlogs = $('ul.myblogs .js_ownblog a');
      if (yourBlogs.length === 0) {
        console.log('no blogs to get');
        return setTimeout((function(_this) {
          return function() {
            return _this.getBlogs();
          };
        })(this), 1000);
      }
      yourBlogs.each(function(index) {
        var $el;
        $el = $(this);
        urls.push($el.attr('href'));
        return sites.push($el.text());
      });
      urls = _.uniq(urls);
      sites = _.uniq(sites);
      blogs = {};
      _results = [];
      for (index = _i = 0, _len = urls.length; _i < _len; index = ++_i) {
        url = urls[index];
        _results.push(blogs[sites[index]] = url);
      }
      return _results;
    }
  };

  editing = false;

  check.getBlogs();

  interval = setInterval(function() {
    if (check.editorVisible() !== editing) {
      editing = check.editorVisible();
      if (editing) {
        return view.addFields();
      } else {
        return view.removeFields();
      }
    }
  }, 500);

  view = {
    addFields: function() {
      console.log('add fields now');
      $('div.row.editor-actions').after("<div class=\"row\" style=\"border-top: rgba(0,0,0,0.3) 1px dashed; border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;\">\n  <div class=\"columns medium-12 small-12\">\n    <div class=\"columns small-1 medium-1\">\n      <i class=\"icon icon-twitter icon-prepend\" style=\"font-size: 25px; margin-top: 12px;\" ></i>\n    </div>\n    <div class=\"columns medium-11 small-11\">\n      <textarea id=\"tweet-box\" class=\"inline no-shadow\" style=\"color: #000; border: none;\" type=\"text\" name=\"tweet\" placeholder=\"Tweet your words\" value=\"\" tabindex=\"6\"></textarea>\n      <span class=\"tweet-char-counter\" style=\"position: absolute; right: 30px; bottom: 20px;\"></span>\n    </div>\n  </div>\n</div>\n<div class=\"row\" style=\"border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;\">\n  <div class=\"columns medium-12 small-12\">\n    <div class=\"columns small-1 medium-1\">\n      <i class=\"icon icon-facebook icon-prepend\" style=\"font-size: 25px; margin-top: 12px;\" ></i>\n    </div>\n    <div class=\"columns medium-11 small-11\">\n      <textarea class=\"inline no-shadow\" style=\"color: #000; border: none;\" type=\"text\" name=\"tweet\" placeholder=\"Facebook your feelings\" value=\"\" tabindex=\"7\"></textarea>\n    </div>\n  </div>\n</div>");
      $('#tweet-box').on('keyup', (function(_this) {
        return function() {
          return _this.setCharCount();
        };
      })(this));
      return setTimeout((function(_this) {
        return function() {
          return _this.setCharCount();
        };
      })(this), 500);
    },
    setCharCount: function() {
      return $('.tweet-char-counter').text(check.countdown());
    },
    removeFields: function() {
      return console.log('remove fields now');
    }
  };

}).call(this);

//# sourceMappingURL=contentscript.js.map
