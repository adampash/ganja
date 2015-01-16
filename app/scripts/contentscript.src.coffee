helper =
  retrieveWindowVariables: (variables) ->
    ret = {}

    scriptContent = ""
    for currVariable in variables
      scriptContent += "if (typeof " + currVariable + " !== 'undefined') document.body.setAttribute('tmp_" + currVariable + "', JSON.stringify(" + currVariable + "));\n"

    script = document.createElement('script')
    script.id = 'tmpScript'
    script.appendChild(document.createTextNode(scriptContent))
    (document.body || document.head || document.documentElement).appendChild(script)

    for currVariable in variables
      ret[currVariable] = JSON.parse $("body").attr("tmp_" + currVariable)
      $("body").removeAttr("tmp_" + currVariable)

    $("#tmpScript").remove()

    ret

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

view =
  addFields: ->
    console.log 'add fields now'
    $('div.row.editor-actions').after(
      """
        <div class="row" style="border-top: rgba(0,0,0,0.3) 1px dashed; border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;">
          <div class="columns medium-12 small-12">
            <div class="columns small-1 medium-1">
              <i class="icon icon-twitter icon-prepend" style="font-size: 25px; margin-top: 12px;" ></i>
            </div>
            <div class="columns medium-11 small-11">
              <textarea id="tweet-box" class="inline no-shadow" style="color: #000; border: none;" type="text" name="tweet" placeholder="Tweet your words" value="" tabindex="6"></textarea>
              <span class="tweet-char-counter" style="position: absolute; right: 30px; bottom: 20px; color: #999999;"></span>
            </div>
          </div>
        </div>
        <div class="row" style="border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;">
          <div class="columns medium-12 small-12">
            <div class="columns small-1 medium-1">
              <i class="icon icon-facebook icon-prepend" style="font-size: 25px; margin-top: 12px;" ></i>
            </div>
            <div class="columns medium-11 small-11">
              <textarea id="facebook-box" class="inline no-shadow" style="color: #000; border: none;" type="text" name="tweet" placeholder="Facebook your feelings" value="" tabindex="7"></textarea>
            </div>
          </div>
        </div>

        <div style="margin-top: 10px;" class="columns small-12 medium-4 medium-push-8">
          <div class="selector-container right"> 
            <div id="social-save-status" style="margin: 5px 20px 0 0; float: left; width: 40px; font-size: 14px;"></div>
            <button id="social-save" class="button tiny primary submit flex-item" tabindex="8">Save Social</button>
          </div>
        </div>

      """
    )
    $('#tweet-box').on 'keyup', =>
      @setCharCount()
    $('#social-save').on 'click', ->
      Socializer.saveSocial()
    setTimeout =>
      @setCharCount()
    , 500

  setCharCount: ->
    $('.tweet-char-counter').text Socializer.countdown()

  removeFields: ->
    console.log 'remove fields now'

init = ->
  pageWin = helper.retrieveWindowVariables(['kinja'])
  if pageWin.kinja? and pageWin.kinja.postMeta?
    Socializer.init(pageWin.kinja)
    blogs = {}
    Socializer.getBlogs (_blogs) ->
      blogs = _blogs
      console.log blogs
    console.log Socializer.getPublishTime(pageWin.kinja)
  else
    setTimeout ->
      init()
    , 100

init()
