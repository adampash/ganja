view =
  root: 'http://localhost:3000'

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

  addFields: (callback) ->
    console.log 'add fields now'
    iconStyle = 'style="margin: .5rem 0; opacity: 0.5;"'
    textareaStyle = 'class="js_taglist-input taglist-input mbn inline-block no-shadow" style="width: 568px; color: #000; border: none; margin-top: 10px;"'
    # $('div.row.editor-actions').after(
    $('div.editor-taglist-wrapper').after(
      """
        <div class="row collapse social_row" style="border-top: rgba(0,0,0,0.3) 1px dashed; border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;">
          <div class="column">
            <span class="js_tag tag">
              <i class="icon icon-twitter" #{iconStyle}></i>
              <div class="js_taglist taglist">
                <span class="js_taglist-tags taglist-tags mbn no-shadow"></span>
                <textarea id="tweet-box" #{textareaStyle} type="text" name="tweet" placeholder="Tweet your words" value="" tabindex="6"></textarea>
                <span class="tweet-char-counter" style="position: absolute; right: 30px; bottom: 20px; color: #999999;"></span>
              </div>
            </span>
          </div>
        </div>


        <div class="row collapse social_row" style="border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;">
          <div class="column">
            <span class="js_tag tag">
              <i class="icon icon-facebook" #{iconStyle}></i>
              <div class="js_taglist taglist">
                <textarea id="facebook-box" #{textareaStyle} type="text" name="tweet" placeholder="Facebook your feelings" value="" tabindex="7"></textarea>
              </div>
            </span>
          </div>
        </div>


        <div style="margin-top: 10px;" class="columns small-12 medium-12>
          <div class="selector-container right">
            <div id="social-save-status" style="margin: 5px 20px 0 0; float: left; width: 300px; font-size: 14px; font-family: ProximaNovaCond;"></div>
          </div>
        </div>

      """
    )
    $('.social_row').on 'click', (el) ->
      $(el.currentTarget).find('textarea').focus()
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
