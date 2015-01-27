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

view =
  root: 'http://localhost:3000'

  loginPrompt: (callback) ->
    $('div.row.editor-actions').after(
      """
        <div class="row socializer-login-prompt" style="border-top: rgba(0,0,0,0.3) 1px dashed; border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;">
          <div class="columns medium-12 small-12">
            <h4>In order to draft Twitter/Facebook posts, log into Gawker Socializer with your Gawker email</h4>
            <button id="socializer-login" class="button tiny secondary flex-item" tabindex="8">Login now</button>
          </div>
        </div>

      """
    )
    $('#socializer-login').on 'click', =>
      child = window.open "#{@root}/signin"

      checkChild = ->
        if (!child.location? or child.closed)
          console.log 'signin window closed'
          clearInterval(timer)
          $('.socializer-login-prompt').remove()
          callback()

      timer = setInterval(checkChild, 500)

  addFields: (callback) ->
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

        <div style="margin-top: 10px;" class="columns small-12 medium-12>
          <div class="selector-container right">
            <div id="social-save-status" style="margin: 5px 20px 0 0; float: left; width: 300px; font-size: 14px; font-family: ProximaNovaCond;"></div>
            <button id="social-draft" class="button tiny secondary flex-item" tabindex="8">Save draft</button>
            <button id="social-save" class="button tiny secondary flex-item" tabindex="8">Ready to publish</button>
          </div>
        </div>

      """
    )
    $('#tweet-box').on 'keyup', =>
      @setCharCount()
    $('#social-save').on 'click', ->
      Socializer.saveSocial(set_to_publish: true)
    $('#social-draft').on 'click', ->
      Socializer.saveSocial(set_to_publish: false)
    setTimeout =>
      @setCharCount()
    , 500
    callback()

  setCharCount: ->
    charCount = Socializer.countdown()
    if charCount < 0 then cssTweak = color: 'red' else cssTweak = {color: '#999'}
    # debugger
    $('.tweet-char-counter').text(charCount).css(cssTweak)

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
