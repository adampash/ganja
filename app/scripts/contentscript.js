(function() {
  var Socializer, dev, helper, init, root, view;

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
    },
    watchAjax: function(callback) {
      var script, scriptContent;
      scriptContent = "setTimeout(function() {\n$(document).ajaxSuccess(function() {\n  debugger;\n  $( \".log\" ).text( \"Triggered ajaxSuccess handler.\" );\n});\n}, 1000);";
      script = document.createElement('script');
      script.id = 'ajaxSuccess';
      script.appendChild(document.createTextNode(scriptContent));
      return (document.body || document.head || document.documentElement).appendChild(script);
    }
  };

  dev = false;

  if (dev) {
    root = "http://localhost:3000";
  } else {
    root = "http://gawker-socializer.herokuapp.com";
  }

  Socializer = {
    root: root,
    init: function(kinja) {
      this.kinja = kinja;
      this.editing = false;
      if (window.location.search.match(/^\?rev=/)) {
        this.updatePublishTime();
      }
      return this.interval = setInterval((function(_this) {
        return function() {
          if (_this.editorVisible() !== _this.editing) {
            _this.editing = _this.editorVisible();
            if (_this.editing) {
              return _this.initEdit();
            }
          }
        };
      })(this), 500);
    },
    initEdit: function() {
      return this.checkLogin((function(_this) {
        return function(logged_in) {
          $('.socializer-login-prompt').remove();
          if (logged_in) {
            view.addFields(function() {
              return _this.fetchSocial(_this.getPostId());
            });
            $('.save.submit').on('click', function() {
              return _this.saveSocial({
                set_to_publish: false
              });
            });
            return $('.publish.submit').on('click', function() {
              return _this.saveSocial({
                set_to_publish: true
              });
            });
          } else {
            return view.loginPrompt(function() {
              return _this.init(_this.kinja);
            });
          }
        };
      })(this));
    },
    checkLogin: function(callback) {
      return $.ajax({
        method: "GET",
        url: "" + this.root + "/login_check",
        success: (function(_this) {
          return function(data) {
            return callback(data.logged_in);
          };
        })(this),
        error: function() {},
        complete: function() {}
      });
    },
    updatePublishTime: function() {
      var params;
      params = {
        publish_at: this.getPublishTime(),
        kinja_id: this.getPostId(),
        method: 'updatePublishTime'
      };
      return chrome.runtime.sendMessage(params);
    },
    fetchSocial: function(postId) {
      return $.ajax({
        method: "GET",
        url: "" + this.root + "/stories/" + postId + ".json",
        success: (function(_this) {
          return function(data) {
            _this.latestSocial = data;
            if (data == null) {
              return;
            }
            $('#tweet-box').val(data.tweet);
            return $('#ap_facebook-box').val(data.fb_post);
          };
        })(this),
        error: function() {},
        complete: function() {}
      });
    },
    editorVisible: function() {
      return $('div.editor:visible').length !== 0 && $('article.post.hentry:visible').length === 0;
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
        urls.push($el.attr('href').replace('//', ''));
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
      return this.kinja.postMeta.post.publishTimeMillis;
    },
    getDomain: function() {
      return this.getBlogs(function(blogs) {
        return blogs[$('button.group-blog-container span').not('.hide').text()];
      });
    },
    getPostId: function() {
      return this.kinja.postMeta.postId;
    },
    verifyTimeSync: function() {},
    getData: function() {
      return {
        tweet: $('#tweet-box').val(),
        author: this.getAuthors(),
        fb_post: $('#ap_facebook-box').val(),
        publish_at: this.getPublishTime(),
        url: this.getURL(),
        title: $('.editable-headline').first().text(),
        domain: this.getDomain(),
        kinja_id: this.getPostId()
      };
    },
    saveSocial: function(opts) {
      var params;
      params = this.getData();
      params.set_to_publish = opts.set_to_publish;
      params.method = 'saveSocial';
      return chrome.runtime.sendMessage(params, function(response) {
        return console.log(response);
      });
    },
    hasSocialPosts: function(data) {
      return data.tweet !== "" || data.fb_post !== "";
    },
    setStatusMessage: function(data) {
      var color, icon, msg, pub_time;
      if (this.hasSocialPosts(data)) {
        pub_time = moment(data.publish_at).format('MM/DD/YY, h:mm a');
        if (data.set_to_publish) {
          color = 'green';
          msg = "Social posts set to go live at " + pub_time;
          icon = "checkmark";
        } else {
          color = 'burlywood';
          msg = "Social posts in draft for " + pub_time;
          icon = "pencil-alt ";
        }
        return $('#social-save-status').html("<i class=\"icon icon-" + icon + " icon-prepend\" style=\"color: " + color + ";\"></i>" + msg).css('color', color);
      } else {
        return $('#social-save-status').empty();
      }
    }
  };

  dev = false;

  if (dev) {
    root = "http://localhost:3000";
  } else {
    root = "http://gawker-socializer.herokuapp.com";
  }

  view = {
    root: root,
    loginPrompt: function(callback) {
      $('div.editor-taglist-wrapper').after("<div class=\"row socializer-login-prompt\" style=\"border-top: rgba(0,0,0,0.3) 1px dashed; border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;\">\n  <div class=\"columns medium-12 small-12\">\n    <h4>In order to draft Twitter/Facebook posts, <a id=\"socializer-login\" href=\"#\">log into Gawker Socializer</a> with your work email</h4>\n  </div>\n</div>\n");
      return $('#socializer-login').on('click', (function(_this) {
        return function() {
          return chrome.runtime.sendMessage({
            method: 'login'
          });
        };
      })(this));
    },
    addFields: function(callback) {
      var iconStyle, textareaStyle;
      console.log('add fields now');
      $('input.js_taglist-input').attr('tabindex', 3);
      iconStyle = 'style="margin: .5rem 0; opacity: 0.5; display: inline-block !important;"';
      textareaStyle = 'class="js_taglist-input taglist-input mbn inline-block no-shadow" style="width: 568px; color: #000; border: none; margin-top: 10px;"';
      $('div.editor-taglist-wrapper').after("<div class=\"row collapse ap_social_row\" style=\"border-top: rgba(0,0,0,0.3) 1px dashed; border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;\">\n  <div class=\"column\">\n    <span class=\"js_tag tag\">\n      <i class=\"icon icon-twitter\" " + iconStyle + "></i>\n      <div class=\"js_taglist taglist\">\n        <span class=\"js_taglist-tags taglist-tags mbn no-shadow\"></span>\n        <textarea id=\"tweet-box\" " + textareaStyle + " type=\"text\" name=\"tweet\" placeholder=\"Tweet your words\" value=\"\" tabindex=\"4\"></textarea>\n        <span class=\"tweet-char-counter\" style=\"position: absolute; right: 30px; bottom: 20px; color: #999999;\"></span>\n      </div>\n    </span>\n  </div>\n</div>\n\n\n<div class=\"row collapse ap_social_row\" style=\"border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;\">\n  <div class=\"column\">\n    <span class=\"js_tag tag\">\n      <i class=\"icon icon-facebook\" " + iconStyle + "></i>\n      <div class=\"js_taglist taglist\">\n        <textarea id=\"ap_facebook-box\" " + textareaStyle + " type=\"text\" name=\"tweet\" placeholder=\"Facebook your feelings\" value=\"\" tabindex=\"4\"></textarea>\n      </div>\n    </span>\n  </div>\n</div>\n\n\n<div style=\"margin-top: 10px;\" class=\"columns small-12 medium-12\">\n  <div class=\"selector-container right\">\n    <div id=\"social-save-status\" style=\"margin: 5px 20px 0 0; float: left; width: 300px; font-size: 14px; font-family: ProximaNovaCond;\"></div>\n  </div>\n</div>\n");
      $('.ap_social_row').on('click', function(el) {
        return $(el.currentTarget).find('textarea').focus();
      });
      $('#tweet-box').on('keyup', (function(_this) {
        return function() {
          return _this.setCharCount();
        };
      })(this));
      $('#social-save').on('click', function() {
        return Socializer.saveSocial({
          set_to_publish: true
        });
      });
      $('#social-draft').on('click', function() {
        return Socializer.saveSocial({
          set_to_publish: false
        });
      });
      setTimeout((function(_this) {
        return function() {
          return _this.setCharCount();
        };
      })(this), 500);
      return callback();
    },
    setCharCount: function() {
      var charCount, cssTweak;
      charCount = Socializer.countdown();
      if (charCount < 0) {
        cssTweak = {
          color: 'red'
        };
      } else {
        cssTweak = {
          color: '#999'
        };
      }
      return $('.tweet-char-counter').text(charCount).css(cssTweak);
    },
    removeFields: function() {
      return console.log('remove fields now');
    }
  };

  init = function() {
    var pageWin;
    pageWin = helper.retrieveWindowVariables(['kinja']);
    if ((pageWin.kinja != null) && (pageWin.kinja.postMeta != null)) {
      return Socializer.init(pageWin.kinja);
    } else {
      return setTimeout(function() {
        return init();
      }, 100);
    }
  };

  chrome.runtime.onMessage.addListener(function(request, sender, callback) {
    if (request.method === 'loginComplete') {
      return Socializer.initEdit();
    }
  });

  init();

}).call(this);

//# sourceMappingURL=contentscript.js.map
