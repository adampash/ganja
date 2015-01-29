Post =
  refresh: (callback) ->
    port = chrome.runtime.connect()

    window.addEventListener "message", (event) =>
      # We only accept messages from ourselves
      if event.source != window
        return

      if event.data.postModel?
        console.log("Content script received: " + event.data.text)
        @post = event.data.postModel
        callback()
        # port.postMessage(event.data.text)
    , false

    ret = {}

    scriptContent = "window.postMessage({postModel: $('.editor').data('modelData')}, '*');"

    script = document.createElement('script')
    script.id = 'tmpScript'
    script.appendChild(document.createTextNode(scriptContent))
    (document.body || document.head || document.documentElement).appendChild(script)

  getData: ->
    tweet: $('#tweet-box').val()
    author: @getAuthors()
    fb_post: $('#ap_facebook-box').val()
    publish_at: @getPublishTime()
    url: @getURL()
    title: $('.editable-headline').first().text()
    domain: @getDomain()
    kinja_id: @getPostId()

  getURL: ->
    url = @post.permalink.replace(/\/preview\//, '/').split('?')[0]
    if url.indexOf('?') != -1 then url.split('?')[0] else url

  getAuthors: ->
    @post.displayAuthorObject.displayName

  getPublishTime: ->
    @post.publishTimeMillis

  getDomain: ->
    @getBlogs (blogs) ->
      blogs[$('button.group-blog-container span').not('.hide').text()]

  getPostId: ->
    @post.id

  getBlogs: (complete) ->
    console.log 'getting blogs'
    urls = []
    sites = []
    yourBlogs = $('ul.myblogs .js_ownblog a')
    if yourBlogs.length is 0
      console.log 'no blogs to get'
      return setTimeout =>
        @post.getBlogs(complete)
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

  getStatus: ->
    @post.status
