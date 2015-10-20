WordCount =
  init: ->
    Dispatcher.on('editor_visible', =>
      @count_words()
    )

  count_words: ->
    @interval = setInterval =>
      words = $('.scribe.editor-inner.post-content')
        .text()
        .replace('tktk.​gawker.​com', '')
      wc = words.split(" ").length
      tk_match = words.match(/(tk)+/gi)
      if tk_match?
        tk_count = tk_match.length
      @wc_view(wc)
      @tk_view(tk_count)
    , 2000

  tk_view: (count=0) ->
    if $('.tk-tracker').length is 0
      $('.date-time-container')
        .append('<span class="tk-tracker ganjmeta"></span>')
    content = ''
    if count > 0
      content = "<b>TK count:</b> #{count}"
    $('.tk-tracker').html(content)

  wc_view: (count=0) ->
    if $('.wc-tracker').length is 0
      $('.date-time-container')
        .append('<span class="wc-tracker ganjmeta"></span>')
    content = ''
    if count > 500
      content = "<b>Word count:</b> #{count} "
    if count > 2000
      content += '<span style="color: red;">Make sure a member of the Politburo has OKed this length </span>'
    $('.wc-tracker').html(content)

