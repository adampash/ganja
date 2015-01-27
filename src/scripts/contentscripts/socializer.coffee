Socializer =
  root: 'http://localhost:3000'

  init: (@kinja) ->
    @editing = false
    params =
      publish_at: @getPublishTime()
      kinja_id: @getPostId()
      method: 'updatePublishTime'
    chrome.runtime.sendMessage params
    @interval = setInterval =>
      unless @editorVisible() == @editing
        @editing = @editorVisible()
        if @editing
          @checkLogin (logged_in) =>
            if logged_in
              view.addFields =>
                @fetchSocial(@getPostId())
              # @addEvents()
              $('.save.submit').on 'click', =>
                @saveSocial(set_to_publish: false)
              $('.publish.submit').on 'click', =>
                @saveSocial(set_to_publish: true)
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
        @latestSocial = data
        # @setStatusMessage(data)
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
      urls.push $el.attr('href').replace('//', '')
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
    @kinja.postMeta.post.publishTimeMillis

  getDomain: ->
    @getBlogs (blogs) ->
      blogs[$('button.group-blog-container span').not('.hide').text()]

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
    # $('#social-save-status').show().text("Saving...")
    params = @getData()
    params.set_to_publish = opts.set_to_publish
    params.method = 'saveSocial'
    chrome.runtime.sendMessage params, (response) ->
      console.log(response)

  hasSocialPosts: (data) ->
    data.tweet != "" or data.fb_post != ""

  setStatusMessage: (data) ->
    if @hasSocialPosts(data)
      pub_time = moment(data.publish_at).format('MM/DD/YY, h:mm a')
      if data.set_to_publish
        color = 'green'
        msg = "Social posts set to go live at #{pub_time}"
        icon = "checkmark"
      else
        color = 'burlywood'
        msg = "Social posts in draft for #{pub_time}"
        icon = "pencil-alt "
      $('#social-save-status').html("<i class=\"icon icon-#{icon} icon-prepend\" style=\"color: #{color};\"></i>#{msg}").css('color', color)
    else
      $('#social-save-status').empty()
