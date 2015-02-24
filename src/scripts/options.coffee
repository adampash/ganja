save = (params, msg, callback) ->
  debugger
  chrome.storage.sync.set params, ->
      # // Update status to let user know options were saved.
      $('.status').text(msg).show()
      setTimeout ->
        $('.status').fadeOut -> $(@).text('')
      , 2000
      callback() if callback?

# $('.pgp_sig, .pgp_public_key, .contact_email').on 'change', ->
#   triggerSave($(@))

triggerSave = (el, msg) ->
  val = el.val()
  key = el.attr('class')
  msg = msg or el.data('msg')
  params = {}
  params[key] = val
  save params, msg

$('.save-button').on 'click', ->
  $('.pgp_sig, .pgp_public_key, .contact_email').each ->
    triggerSave($(@), "Saved")

$ ->
  chrome.storage.sync.get
    contact_email: ''
    pgp_sig: ''
    pgp_public_key: ''
  , (items) ->
    $('.contact_email').val(items.contact_email)
    $('.pgp_sig').val(items.pgp_sig)
    $('.pgp_public_key').val(items.pgp_public_key)
