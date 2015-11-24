(function() {
  var ContactInfo, Post, Socializer, Utils, WordCount, helper, init, root, view;

  ContactInfo = {
    info_added: false,
    init: function() {
      chrome.storage.sync.get({
        contact_email: '',
        pgp_sig: '',
        pgp_public_key: ''
      }, (function(_this) {
        return function(items) {
          _this.email = items.contact_email;
          _this.pgp_sig = items.pgp_sig;
          return _this.pgp_public_key = items.pgp_public_key;
        };
      })(this));
      return Dispatcher.on('post_refresh', (function(_this) {
        return function(post) {
          var editor_text;
          if (!((post.permalink != null) || _this.info_added)) {
            console.log('should add something to the bottom of the post');
            editor_text = $('.editor-inner').text();
            if ((editor_text.length === 1 && editor_text.charCodeAt(0) === 8203) || editor_text.length === 0) {
              return $('.editor-inner').append(_this.info());
            }
          }
        };
      })(this));
    },
    info: function() {
      var text;
      if (this.email !== '') {
        text = "<div id=\"editorial_labs_contact_info\"><hr><p><em><small>Contact the author at <a href=\"mailto:" + this.email + "\">" + this.email + "</a>.";
        if (this.pgp_sig !== '') {
          text += "<br><a href=\"" + this.pgp_public_key + "\" target=\"_blank\">Public PGP key</a>";
          text += "<br>PGP fingerprint: " + this.pgp_sig;
        }
        return text += "</small></em></p></div>";
      }
    }
  };

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

  Post = {
    refresh: function(callback) {
      var port, ret, script, scriptContent;
      port = chrome.runtime.connect();
      window.addEventListener("message", (function(_this) {
        return function(event) {
          if (event.source !== window) {
            return;
          }
          if (event.data.postModel != null) {
            console.log("Content script received: " + event.data.text);
            _this.post = event.data.postModel;
            Dispatcher.trigger('post_refresh', _this.post);
            if (callback != null) {
              return callback();
            }
          }
        };
      })(this), false);
      ret = {};
      scriptContent = "window.postMessage({postModel: $('.editor').data('modelData')}, '*');";
      script = document.createElement('script');
      script.id = 'tmpScript';
      script.appendChild(document.createTextNode(scriptContent));
      return (document.body || document.head || document.documentElement).appendChild(script);
    },
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
    getURL: function() {
      var url;
      url = this.post.permalink.replace(/\/preview\//, '/').split('?')[0];
      if (url.indexOf('?') !== -1) {
        return url.split('?')[0];
      } else {
        return url;
      }
    },
    getAuthors: function() {
      return this.post.displayAuthorObject.displayName;
    },
    getPublishTime: function() {
      return this.post.publishTimeMillis;
    },
    getDomain: function() {
      var blog;
      blog = _.find(this.post.blogList, (function(_this) {
        return function(blog) {
          return blog.id === _this.post.defaultBlogId;
        };
      })(this));
      return blog.canonicalHost;
    },
    getPostId: function() {
      return this.post.id;
    },
    getBlogs: function(complete) {
      var blogs, index, sites, url, urls, yourBlogs, _i, _len;
      console.log('getting blogs');
      urls = [];
      sites = [];
      yourBlogs = $('ul.myblogs a');
      if (yourBlogs.length === 0) {
        console.log('no blogs to get');
        return setTimeout((function(_this) {
          return function() {
            return _this.post.getBlogs(complete);
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
    getStatus: function() {
      return this.post.status;
    }
  };

  root = config.socializer_url();

  Socializer = {
    root: root,
    init: function() {
      this.post = Post;
      return Dispatcher.on('editor_visible', (function(_this) {
        return function() {
          return _this.post.refresh(function() {
            return _this.initEdit();
          });
        };
      })(this));
    },
    initEdit: function() {
      return this.checkLogin((function(_this) {
        return function(logged_in) {
          $('.socializer-login-prompt').remove();
          if (logged_in) {
            view.addFields(_this.post.getPostId() != null, function() {
              return _this.fetchSocial(_this.post.getPostId());
            });
            if (_this.post.getStatus() === "DRAFT") {
              $('.publish.submit').on('click', function() {
                return setTimeout(function() {
                  return $('.kinja-modal button.js_submit').on('click', function() {
                    return _this.saveSocial({
                      set_to_publish: true
                    });
                  });
                }, 100);
              });
              return $('.save.submit').on('click', function() {
                return _this.saveSocial({
                  set_to_publish: false
                });
              });
            } else {
              $('.save.submit').on('click', function() {
                return setTimeout(function() {
                  return $('.kinja-modal button.js_submit').on('click', function() {
                    return _this.saveSocial({
                      set_to_publish: false
                    });
                  });
                }, 100);
              });
              return $('.publish.submit').on('click', function() {
                return _this.saveSocial({
                  set_to_publish: true
                });
              });
            }
          } else {
            return view.loginPrompt(function() {
              return _this.init();
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
        publish_at: this.post.getPublishTime(),
        kinja_id: this.post.getPostId(),
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
    countdown: function() {
      if (!($('#tweet-box').length > 0)) {
        return;
      }
      return 140 - 24 - $('#tweet-box').val().length;
    },
    verifyTimeSync: function() {},
    saveSocial: function(opts) {
      return this.post.refresh((function(_this) {
        return function() {
          var params;
          params = _this.post.getData();
          params.set_to_publish = opts.set_to_publish;
          params.method = 'saveSocial';
          return chrome.runtime.sendMessage(params, function(response) {
            return console.log(response);
          });
        };
      })(this));
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

  Utils = {
    init: function() {
      if (this.interval != null) {
        clearInterval(this.interval);
      }
      return this.interval = setInterval((function(_this) {
        return function() {
          if (_this.editorVisible()) {
            return clearInterval(_this.interval);
          }
        };
      })(this), 500);
    },
    editorVisible: function() {
      if ($('div.editor:visible').length !== 0 && $('article.post.hentry:visible').length === 0) {
        return Dispatcher.trigger('editor_visible');
      }
    }
  };

  root = config.socializer_url();

  view = {
    root: root,
    loginPrompt: function(callback) {
      $('div.editor-taglist-wrapper').after("<div class=\"row socializer-login-prompt\">\n  <div class=\"columns medium-12 small-12\">\n    <h4>In order to draft Twitter/Facebook posts, <a id=\"socializer-login\" href=\"#\">log into Gawker Socializer</a> with your work email</h4>\n  </div>\n</div>\n");
      return $('#socializer-login').on('click', (function(_this) {
        return function() {
          return chrome.runtime.sendMessage({
            method: 'login'
          });
        };
      })(this));
    },
    addFields: function(canEdit, callback) {
      var content, iconStyle, message, textareaStyle;
      if ($('.ap_socializer_extension_fields').length > 0) {
        return;
      }
      console.log('add fields now');
      $('input.js_taglist-input').attr('tabindex', 3);
      iconStyle = '';
      textareaStyle = 'class="ap_social_textarea js_taglist-input taglist-input mbn inline-block no-shadow"';
      message = "";
      if (canEdit) {
        content = "<div class=\"ap_socializer_extension_fields\">\n  <div style=\"position: relative;\">\n    " + message + "\n    <div class=\"row collapse ap_social_row\">\n      <div class=\"column\">\n        <span class=\"js_tag tag\">\n          <i class=\"icon icon-twitter social-icons\" " + iconStyle + "></i>\n          <div class=\"js_taglist taglist\">\n            <span class=\"js_taglist-tags taglist-tags mbn no-shadow\"></span>\n            <textarea id=\"tweet-box\" " + textareaStyle + " type=\"text\" name=\"tweet\" placeholder=\"Tweet your thoughts\" value=\"\" tabindex=\"4\"></textarea>\n            <span class=\"tweet-char-counter\"></span>\n          </div>\n        </span>\n      </div>\n    </div>\n\n\n    <div class=\"row collapse ap_social_row ap_social_row_fb\">\n      <div class=\"column\">\n        <span class=\"js_tag tag\">\n          <i class=\"icon icon-facebook social-icons\" " + iconStyle + "></i>\n          <div class=\"js_taglist taglist\">\n            <textarea id=\"ap_facebook-box\" " + textareaStyle + " type=\"text\" name=\"tweet\" placeholder=\"Facebook your feelings\" value=\"\" tabindex=\"4\"></textarea>\n          </div>\n        </span>\n      </div>\n    </div>\n  </div>\n</div>";
      } else {
        content = '<div class="ap_socializer_extension_fields"><h5 class="h5-message">Save your first draft to edit social posts</h5></div>';
      }
      $('div.editor-taglist-wrapper').after(content);
      $('.ap_social_row').on('click', function(el) {
        return $(el.currentTarget).find('textarea').focus();
      });
      $('#tweet-box').on('keyup', (function(_this) {
        return function() {
          return _this.setCharCount();
        };
      })(this));
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

  WordCount = {
    init: function() {
      return Dispatcher.on('editor_visible', (function(_this) {
        return function() {
          return _this.count_words();
        };
      })(this));
    },
    count_words: function() {
      return this.interval = setInterval((function(_this) {
        return function() {
          var tk_count, tk_match, wc, words;
          words = $('.scribe.editor-inner.post-content').text().replace('tktk.​gawker.​com', '');
          wc = words.split(" ").length;
          tk_match = words.match(/(tk)+/gi);
          if (tk_match != null) {
            tk_count = tk_match.length;
          }
          _this.wc_view(wc);
          return _this.tk_view(tk_count);
        };
      })(this), 2000);
    },
    tk_view: function(count) {
      var content;
      if (count == null) {
        count = 0;
      }
      if ($('.tk-tracker').length === 0) {
        $('.date-time-container').append('<span class="tk-tracker ganjmeta"></span>');
      }
      content = '';
      if (count > 0) {
        content = "<b>TK count:</b> " + count;
      }
      return $('.tk-tracker').html(content);
    },
    wc_view: function(count) {
      var content;
      if (count == null) {
        count = 0;
      }
      if ($('.wc-tracker').length === 0) {
        $('.date-time-container').append('<span class="wc-tracker ganjmeta"></span>');
      }
      content = '';
      if (count > 500) {
        content = "<b>Word count:</b> " + count + " ";
      }
      return $('.wc-tracker').html(content);
    }
  };

  this.Dispatcher = _.clone(Backbone.Events);

  init = function() {
    Socializer.init();
    ContactInfo.init();
    Utils.init();
    return WordCount.init();
  };

  chrome.runtime.onMessage.addListener(function(request, sender, callback) {
    if (request.method === 'loginComplete') {
      return Socializer.initEdit();
    }
  });

  init();

}).call(this);

//# sourceMappingURL=contentscript.js.map
