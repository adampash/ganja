Socializer =
  root: 'http://localhost:3000'
  init: (@kinja) ->
    @editing = false
    @interval = setInterval =>
      unless @editorVisible() == @editing
        @editing = @editorVisible()
        if @editing
          @checkLogin (logged_in) =>
            if logged_in
              view.addFields =>
                @fetchSocial(@getPostId())
            else
              view.loginPrompt =>
                @init(@kinja)
        # else
        #   view.removeFields()
    , 500

  checkLogin: (callback) ->
    $.ajax
      method: "GET"
      url: "#{@root}/login_check"
      success: (data) =>
        callback data.logged_in
      error: ->
      complete: ->

  fetchSocial: (postId) ->
    $.ajax
      method: "GET"
      url: "#{@root}/stories/#{postId}.json"
      success: (data) =>
        $('#tweet-box').val(data.tweet)
        $('#facebook-box').val(data.fb_post)
        @setStatusMessage(data)
      error: ->
      complete: ->

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

  saveSocial: (opts) ->
    $('#social-save-status').show().text("Saving...")
    params = @getData()
    params.set_to_publish = opts.set_to_publish
    $.ajax
      url: "http://localhost:3000/stories"
      method: "POST"
      data: params
      success: (data) =>
        # $('#social-save-status').text("Saved")
        $('#tweet-box').focus()
        # setTimeout =>
        @setStatusMessage(data)
        # , 500
      error: ->
        $('#social-save-status').text("Something went wrong").delay(500).fadeOut()
        $('#tweet-box').focus()

  setStatusMessage: (data) ->
    if data.set_to_publish
      $('#social-save-status').text "Social posts set to publish at #{new Date(data.publish_at)}"
    else
      $('#social-save-status').text "Social posts in draft"
