(function() {
  var Socializer, helper, init, view;

  helper = {
    retrieveWindowVariables: function(variables) {
      var currVariable, ret, script, scriptContent, _i, _j, _len, _len1;
      ret = {};
      scriptContent = "";
      for (_i = 0, _len = variables.length; _i < _len; _i++) {
        currVariable = variables[_i];
        scriptContent += "if (typeof " + currVariable + " !== 'undefined') document.body.setAttribute('tmp_" + currVariable + "', JSON.stringify(" + currVariable + "));\n";
      }
      script = document.createElement('script');
      script.id = 'tmpScript';
      script.appendChild(document.createTextNode(scriptContent));
      (document.body || document.head || document.documentElement).appendChild(script);
      for (_j = 0, _len1 = variables.length; _j < _len1; _j++) {
        currVariable = variables[_j];
        ret[currVariable] = JSON.parse($("body").attr("tmp_" + currVariable));
        $("body").removeAttr("tmp_" + currVariable);
      }
      $("#tmpScript").remove();
      return ret;
    }
  };

  Socializer = {
    init: function(kinja) {
      this.kinja = kinja;
      this.editing = false;
      return this.interval = setInterval((function(_this) {
        return function() {
          if (_this.editorVisible() !== _this.editing) {
            _this.editing = _this.editorVisible();
            if (_this.editing) {
              return view.addFields();
            }
          }
        };
      })(this), 500);
    },
    editorVisible: function() {
      return $('div.editor:visible').length !== 0;
    },
    countdown: function() {
      return 140 - 24 - $('#tweet-box').val().length;
    },
    getBlogs: function(complete) {
      var blogs, index, sites, url, urls, yourBlogs, _i, _len;
      console.log('getting blogs');
      urls = [];
      sites = [];
      yourBlogs = $('ul.myblogs .js_ownblog a');
      if (yourBlogs.length === 0) {
        console.log('no blogs to get');
        return setTimeout((function(_this) {
          return function() {
            return _this.getBlogs(complete);
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
      for (index = _i = 0, _len = urls.length; _i < _len; index = ++_i) {
        url = urls[index];
        blogs[sites[index]] = url;
      }
      return complete(blogs);
    },
    getURL: function() {
      return window.location.href.replace(/\/preview\//, '/').split('?')[0];
    },
    getAuthors: function() {
      return this.kinja.postMeta.authors;
    },
    getPublishTime: function() {
      return new Date(this.kinja.postMeta.post.publishTimeMillis);
    },
    getDomain: function() {
      return this.getURL().match(/^https?\:\/\/([^\/?#]+)(?:[\/?#]|$)/i)[1];
    },
    getPostId: function() {
      return this.kinja.postMeta.postId;
    },
    verifyTimeSync: function() {},
    getData: function() {
      return {
        tweet: $('#tweet-box').val(),
        author: this.getAuthors(),
        fb_post: $('#facebook-box').val(),
        publish_at: this.getPublishTime(),
        url: this.getURL(),
        title: $('.editable-headline').first().text(),
        domain: this.getDomain(),
        kinja_id: this.getPostId()
      };
    },
    saveSocial: function() {
      $('#social-save-status').show().text("Saving...");
      $.ajax({
        url: "http://localhost:3000/stories",
        method: "POST",
        data: this.getData()
      });
      return setTimeout(function() {
        $('#social-save-status').text("Saved").delay(500).fadeOut();
        return $('#tweet-box').focus();
      }, 1000);
    }
  };

  view = {
    addFields: function() {
      console.log('add fields now');
      $('div.row.editor-actions').after("<div class=\"row\" style=\"border-top: rgba(0,0,0,0.3) 1px dashed; border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;\">\n  <div class=\"columns medium-12 small-12\">\n    <div class=\"columns small-1 medium-1\">\n      <i class=\"icon icon-twitter icon-prepend\" style=\"font-size: 25px; margin-top: 12px;\" ></i>\n    </div>\n    <div class=\"columns medium-11 small-11\">\n      <textarea id=\"tweet-box\" class=\"inline no-shadow\" style=\"color: #000; border: none;\" type=\"text\" name=\"tweet\" placeholder=\"Tweet your words\" value=\"\" tabindex=\"6\"></textarea>\n      <span class=\"tweet-char-counter\" style=\"position: absolute; right: 30px; bottom: 20px; color: #999999;\"></span>\n    </div>\n  </div>\n</div>\n<div class=\"row\" style=\"border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;\">\n  <div class=\"columns medium-12 small-12\">\n    <div class=\"columns small-1 medium-1\">\n      <i class=\"icon icon-facebook icon-prepend\" style=\"font-size: 25px; margin-top: 12px;\" ></i>\n    </div>\n    <div class=\"columns medium-11 small-11\">\n      <textarea id=\"facebook-box\" class=\"inline no-shadow\" style=\"color: #000; border: none;\" type=\"text\" name=\"tweet\" placeholder=\"Facebook your feelings\" value=\"\" tabindex=\"7\"></textarea>\n    </div>\n  </div>\n</div>\n\n<div style=\"margin-top: 10px;\" class=\"columns small-12 medium-4 medium-push-8\">\n  <div class=\"selector-container right\"> \n    <div id=\"social-save-status\" style=\"margin: 5px 20px 0 0; float: left; width: 40px; font-size: 14px;\"></div>\n    <button id=\"social-save\" class=\"button tiny primary submit flex-item\" tabindex=\"8\">Save Social</button>\n  </div>\n</div>\n");
      $('#tweet-box').on('keyup', (function(_this) {
        return function() {
          return _this.setCharCount();
        };
      })(this));
      $('#social-save').on('click', function() {
        return Socializer.saveSocial();
      });
      return setTimeout((function(_this) {
        return function() {
          return _this.setCharCount();
        };
      })(this), 500);
    },
    setCharCount: function() {
      return $('.tweet-char-counter').text(Socializer.countdown());
    },
    removeFields: function() {
      return console.log('remove fields now');
    }
  };

  init = function() {
    var blogs, pageWin;
    pageWin = helper.retrieveWindowVariables(['kinja']);
    if ((pageWin.kinja != null) && (pageWin.kinja.postMeta != null)) {
      Socializer.init(pageWin.kinja);
      blogs = {};
      Socializer.getBlogs(function(_blogs) {
        blogs = _blogs;
        return console.log(blogs);
      });
      return console.log(Socializer.getPublishTime(pageWin.kinja));
    } else {
      return setTimeout(function() {
        return init();
      }, 100);
    }
  };

  init();

}).call(this);

//# sourceMappingURL=contentscript.js.map
