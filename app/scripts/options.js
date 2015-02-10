(function() {
  console.log('options');

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
      contact_email: ''
    }, function(items) {
      return $('.contact_email').val(items.contact_email);
    });
  });

}).call(this);

//# sourceMappingURL=options.js.map
