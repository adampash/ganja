(function() {
  console.log('options');

  $('.pgp_sig').on('change', function() {
    var sig;
    sig = $(this).val();
    return chrome.storage.sync.set({
      pgp_sig: sig
    }, function() {
      $('.status').text('PGP Signature saved.').show();
      return setTimeout(function() {
        return $('.status').fadeOut(function() {
          return $(this).text('');
        });
      }, 2000);
    });
  });

  $('.pgp_public_key').on('change', function() {
    var key;
    key = $(this).val();
    return chrome.storage.sync.set({
      pgp_public_key: key
    }, function() {
      $('.status').text('PGP Public Key link saved.').show();
      return setTimeout(function() {
        return $('.status').fadeOut(function() {
          return $(this).text('');
        });
      }, 2000);
    });
  });

  $('.contact_email').on('change', function() {
    var email;
    email = $(this).val();
    console.log(email);
    return chrome.storage.sync.set({
      contact_email: email
    }, function() {
      $('.status').text('Email saved.').show();
      return setTimeout(function() {
        return $('.status').fadeOut(function() {
          return $(this).text('');
        });
      }, 2000);
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
