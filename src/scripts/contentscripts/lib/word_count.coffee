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
    # if count > 500
    content = "<b>Word count:</b> #{count} "
    # if count > 2500
    #   content += '<span style="color: #610200; font-size: 11px;">&nbsp;This post is over 2,500 words. Make sure a member of central edit has looked at it. </span>'
    $('.wc-tracker').html(content)
