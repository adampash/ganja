Utils =
  init: ->
    clearInterval @interval if @interval?
    @interval = setInterval =>
      if @editorVisible()
        clearInterval @interval
    , 500
  editorVisible: ->
    if $('div.editor:visible').length != 0 and $('article.post.hentry:visible').length is 0
      Dispatcher.trigger('editor_visible')
