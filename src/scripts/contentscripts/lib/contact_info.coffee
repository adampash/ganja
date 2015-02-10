ContactInfo =
  info_added: false
  init: ->
    chrome.storage.sync.get
      contact_email: ''
    , (items) =>
      @email = items.contact_email
    Dispatcher.on 'post_refresh', (post) =>
      unless post.permalink? or @info_added
        console.log 'should add something to the bottom of the post'
        editor_text = $('.editor-inner').text()
        if editor_text.length is 1 and editor_text.charCodeAt(0) is 8203
          $('.editor-inner').append(@info())

  info: ->
    unless @email is ''
      "<hr><p><i>Contact the author at <a href=\"mailto:#{@email}\">#{@email}</a>.</i></p>"

