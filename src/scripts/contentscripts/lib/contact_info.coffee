ContactInfo =
  info_added: false
  init: ->
    Dispatcher.on 'post_refresh', (post) ->
      unless post.permalink? or @info_added
        console.log 'should add something to the bottom of the post'
        # @info_added = true

