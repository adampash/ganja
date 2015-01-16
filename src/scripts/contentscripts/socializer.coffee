Socializer =
  init: (@kinja) ->
    @editing = false
    @interval = setInterval =>
      unless @editorVisible() == @editing
        @editing = @editorVisible()
        if @editing
          view.addFields()
        # else
        #   view.removeFields()
    , 500

  editorVisible: ->
    $('div.editor:visible').length != 0

  countdown: ->
    140 - 24 - $('#tweet-box').val().length

  getBlogs: (complete) ->
    console.log 'getting blogs'
    urls = []
    sites = []
    yourBlogs = $('ul.myblogs .js_ownblog a')
    if yourBlogs.length is 0
      console.log 'no blogs to get'
      return setTimeout =>
        @getBlogs(complete)
      , 1000
    yourBlogs.each (index) ->
      $el = $(@)
      urls.push $el.attr('href')
      sites.push $el.text()

    urls = _.uniq urls
    sites = _.uniq sites

    blogs = {}
    for url, index in urls
      blogs[sites[index]] = url

    complete(blogs)

  getURL: ->
    window.location.href.replace(/\/preview\//, '/').split('?')[0]

  getAuthors: ->
    @kinja.postMeta.authors

  getPublishTime: ->
    new Date(@kinja.postMeta.post.publishTimeMillis)

  getDomain: ->
    @getURL().match(/^https?\:\/\/([^\/?#]+)(?:[\/?#]|$)/i)[1]

  getPostId: ->
    @kinja.postMeta.postId

  verifyTimeSync: ->

  getData: ->
    tweet: $('#tweet-box').val()
    author: @getAuthors()
    fb_post: $('#facebook-box').val()
    publish_at: @getPublishTime()
    url: @getURL()
    title: $('.editable-headline').first().text()
    domain: @getDomain()
    kinja_id: @getPostId()

  saveSocial: ->
    $('#social-save-status').show().text("Saving...")
    $.ajax
      url: "http://localhost:3000/stories"
      method: "POST"
      data: @getData()
    setTimeout ->
      $('#social-save-status').text("Saved").delay(500).fadeOut()
      $('#tweet-box').focus()
    , 1000
