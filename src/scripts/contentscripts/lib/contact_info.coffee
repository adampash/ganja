ContactInfo =
  info_added: false
  init: ->
    Dispatcher.on 'post_refresh', (post) ->
      unless post.permalink? or @info_added
        console.log 'should add something to the bottom of the post'
        editor_text = $('.editor-inner').text()
        if editor_text.length is 1 and editor_text.charCodeAt(0) is 8203
          $('.editor-inner').html("<p><i>Contact the author of this post <a href=\"#\">via email</a>.</i></p>")
        # @info_added = true

