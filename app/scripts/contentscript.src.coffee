ContactInfo =
  info_added: false
  init: ->
    Dispatcher.on 'post_refresh', (post) =>
      unless post.permalink? or @info_added
        console.log 'should add something to the bottom of the post'
        editor_text = $('.editor-inner').text()
        if editor_text.length is 1 and editor_text.charCodeAt(0) is 8203
          $('.editor-inner').append(@info())

  info: ->
    "<hr><p><i>Contact the author <a href=\"#\">here</a>.</i></p>"


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

  watchAjax: (callback) ->
    scriptContent = """
      setTimeout(function() {
      $(document).ajaxSuccess(function() {
        debugger;
        $( ".log" ).text( "Triggered ajaxSuccess handler." );
      });
      }, 1000);
      """
    script = document.createElement('script')
    script.id = 'ajaxSuccess'
    script.appendChild(document.createTextNode(scriptContent))
    (document.body || document.head || document.documentElement).appendChild(script)

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
        Dispatcher.trigger('post_refresh', @post)
        callback() if callback?
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

root = config.socializer_url()

Socializer =
  root: root

  init: () ->
    @editing = false
    @post = Post
    @interval = setInterval =>
      unless @editorVisible() == @editing
        @editing = @editorVisible()
        if @editing
          @post.refresh()
          @initEdit()
    , 500

  initEdit: ->
    @checkLogin (logged_in) =>
      $('.socializer-login-prompt').remove()
      if logged_in
        view.addFields @post.getPostId()?, =>
          @fetchSocial(@post.getPostId())
        if @post.getStatus() is "DRAFT"
          $('.publish.submit').on 'click', =>
            setTimeout =>
              $('.kinja-modal button.js_submit').on 'click', =>
                @saveSocial(set_to_publish: true)
            , 100
          $('.save.submit').on 'click', =>
            @saveSocial(set_to_publish: false)
        else
          $('.save.submit').on 'click', =>
            setTimeout =>
              $('.kinja-modal button.js_submit').on 'click', =>
                @saveSocial(set_to_publish: false)
            , 100
          $('.publish.submit').on 'click', =>
            @saveSocial(set_to_publish: true)
      else
        view.loginPrompt =>
          @init()
  # else
  #   view.removeFields()

  checkLogin: (callback) ->
    $.ajax
      method: "GET"
      url: "#{@root}/login_check"
      success: (data) =>
        callback data.logged_in
      error: ->
      complete: ->

  updatePublishTime: ->
    params =
      publish_at: @post.getPublishTime()
      kinja_id: @post.getPostId()
      method: 'updatePublishTime'
    chrome.runtime.sendMessage params

  fetchSocial: (postId) ->
    $.ajax
      method: "GET"
      url: "#{@root}/stories/#{postId}.json"
      success: (data) =>
        @latestSocial = data
        return unless data?
        $('#tweet-box').val(data.tweet)
        $('#ap_facebook-box').val(data.fb_post)
      error: ->
      complete: ->

  editorVisible: ->
    if $('div.editor:visible').length != 0 and $('article.post.hentry:visible').length is 0
      Dispatcher.trigger('editor_visible')
      true
    else
      false

  countdown: ->
    return unless $('#tweet-box').length > 0
    140 - 24 - $('#tweet-box').val().length

  verifyTimeSync: ->

  saveSocial: (opts) ->
    @post.refresh =>
      params = @post.getData()
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

root = config.socializer_url()

view =
  root: root

  loginPrompt: (callback) ->
    $('div.editor-taglist-wrapper').after(
      """
        <div class="row socializer-login-prompt" style="border-top: rgba(0,0,0,0.3) 1px dashed; border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;">
          <div class="columns medium-12 small-12">
            <h4>In order to draft Twitter/Facebook posts, <a id="socializer-login" href="#">log into Gawker Socializer</a> with your work email</h4>
          </div>
        </div>

      """
    )
    $('#socializer-login').on 'click', =>
      chrome.runtime.sendMessage method: 'login'

  addFields: (canEdit, callback) ->
    console.log 'add fields now'
    $('input.js_taglist-input').attr('tabindex', 3)
    # $('[TabIndex*="5"]').attr('tabindex', -1)
    iconStyle = 'style="margin: .5rem 0; opacity: 0.5; display: inline-block !important;"'
    textareaStyle = 'class="ap_social_textarea js_taglist-input taglist-input mbn inline-block no-shadow" style="width: 568px; color: #000; border: none; margin-top: 10px;"'
    # $('div.row.editor-actions').after(
    message = ""
    if canEdit
      content =
        """
        <div style="position: relative;">
          #{message}
          <div class="row collapse ap_social_row" style="border-top: rgba(0,0,0,0.3) 1px dashed; border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;">
            <div class="column">
              <span class="js_tag tag">
                <i class="icon icon-twitter" #{iconStyle}></i>
                <div class="js_taglist taglist">
                  <span class="js_taglist-tags taglist-tags mbn no-shadow"></span>
                  <textarea id="tweet-box" #{textareaStyle} type="text" name="tweet" placeholder="Tweet your words" value="" tabindex="4"></textarea>
                  <span class="tweet-char-counter" style="position: absolute; right: 30px; bottom: 20px; color: #999999;"></span>
                </div>
              </span>
            </div>
          </div>


          <div class="row collapse ap_social_row" style="margin-top: 10px; padding-top: 10px;">
            <div class="column">
              <span class="js_tag tag">
                <i class="icon icon-facebook" #{iconStyle}></i>
                <div class="js_taglist taglist">
                  <textarea id="ap_facebook-box" #{textareaStyle} type="text" name="tweet" placeholder="Facebook your feelings" value="" tabindex="4"></textarea>
                </div>
              </span>
            </div>
          </div>
        </div>
        """
    else
      content = '<h5 style="text-align: center; color: #999;">Save your first draft to edit social posts</h5>'
    $('div.editor-taglist-wrapper').after(content)
    $('.ap_social_row').on 'click', (el) ->
      $(el.currentTarget).find('textarea').focus()
    $('#tweet-box').on 'keyup', =>
      @setCharCount()
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

@Dispatcher = _.clone(Backbone.Events)

init = ->
  Socializer.init()
  ContactInfo.init()

chrome.runtime.onMessage.addListener (request, sender, callback) ->
  if request.method is 'loginComplete'
    Socializer.initEdit()

init()
