view =
  root: 'http://localhost:3000'

  loginPrompt: (callback) ->
    $('div.row.editor-actions').after(
      """
        <div class="row socializer-login-prompt" style="border-top: rgba(0,0,0,0.3) 1px dashed; border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;">
          <div class="columns medium-12 small-12">
            <h4>In order to edit Twitter/Facebook posts, you need to log into the tool with your Gawker email</h4>
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
            <button id="social-draft" class="button tiny secondary flex-item" tabindex="8">Save Social Draft</button>
            <button id="social-save" class="button tiny secondary flex-item" tabindex="8">Schedule to publish</button>
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
    $('.tweet-char-counter').text Socializer.countdown()

  removeFields: ->
    console.log 'remove fields now'
