console.log 'options'

$('.pgp_sig').on 'change', ->
  sig = $(@).val()
  chrome.storage.sync.set
    pgp_sig: sig
  , () ->
      # // Update status to let user know options were saved.
    $('.status').text('PGP Signature saved.').show()
    setTimeout ->
      $('.status').fadeOut -> $(@).text('')
    , 2000
$('.pgp_public_key').on 'change', ->
  key = $(@).val()
  chrome.storage.sync.set
    pgp_public_key: key
  , () ->
      # // Update status to let user know options were saved.
    $('.status').text('PGP Public Key link saved.').show()
    setTimeout ->
      $('.status').fadeOut -> $(@).text('')
    , 2000
$('.contact_email').on 'change', ->
  email = $(@).val()
  console.log email
  chrome.storage.sync.set
    contact_email: email
  , () ->
      # // Update status to let user know options were saved.
    $('.status').text('Email saved.').show()
    setTimeout ->
      $('.status').fadeOut -> $(@).text('')
    , 2000



$ ->
  chrome.storage.sync.get
    contact_email: ''
    pgp_sig: ''
    pgp_public_key: ''
  , (items) ->
    $('.contact_email').val(items.contact_email)
    $('.pgp_sig').val(items.pgp_sig)
    $('.pgp_public_key').val(items.pgp_public_key)
