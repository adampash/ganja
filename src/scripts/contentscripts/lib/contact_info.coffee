ContactInfo =
  info_added: false
  init: ->
    Dispatcher.on 'post_refresh', (post) =>
      unless post.permalink? or @info_added
        console.log 'should add something to the bottom of the post'
        editor_text = $('.editor-inner').text()
        if editor_text.length is 1 and editor_text.charCodeAt(0) is 8203
          $('.editor-inner').append(@info())

  info: ->
    "<hr><p><i>Contact the author <a href=\"#\">here</a>.</i></p>"

