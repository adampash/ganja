dev = false

if dev
  root = "http://localhost:3000"
else
  root = "http://gawker-socializer.herokuapp.com"

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
        view.addFields =>
          @fetchSocial(@post.getPostId())
        # @addEvents()
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
    $('div.editor:visible').length != 0 and $('article.post.hentry:visible').length is 0

  countdown: ->
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
