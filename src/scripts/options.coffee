console.log 'options'

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
  , (items) ->
    $('.contact_email').val(items.contact_email)
