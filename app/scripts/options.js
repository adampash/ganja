(function() {
  var save, triggerSave;

  save = function(params, msg, callback) {
    debugger;
    return chrome.storage.sync.set(params, function() {
      $('.status').text(msg).show();
      setTimeout(function() {
        return $('.status').fadeOut(function() {
          return $(this).text('');
        });
      }, 2000);
      if (callback != null) {
        return callback();
      }
    });
  };

  triggerSave = function(el, msg) {
    var key, params, val;
    val = el.val();
    key = el.attr('class');
    msg = msg || el.data('msg');
    params = {};
    params[key] = val;
    return save(params, msg);
  };

  $('.save-button').on('click', function() {
    return $('.pgp_sig, .pgp_public_key, .contact_email').each(function() {
      return triggerSave($(this), "Saved");
    });
  });

  $(function() {
    return chrome.storage.sync.get({
      contact_email: '',
      pgp_sig: '',
      pgp_public_key: ''
    }, function(items) {
      $('.contact_email').val(items.contact_email);
      $('.pgp_sig').val(items.pgp_sig);
      return $('.pgp_public_key').val(items.pgp_public_key);
    });
  });

}).call(this);

//# sourceMappingURL=options.js.map
