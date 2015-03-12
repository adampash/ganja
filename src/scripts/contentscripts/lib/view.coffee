root = config.socializer_url()

view =
  root: root

  loginPrompt: (callback) ->
    $('div.editor-taglist-wrapper').after(
      """
        <div class="row socializer-login-prompt">
          <div class="columns medium-12 small-12">
            <h4>In order to draft Twitter/Facebook posts, <a id="socializer-login" href="#">log into Gawker Socializer</a> with your work email</h4>
          </div>
        </div>

      """
    )
    $('#socializer-login').on 'click', =>
      chrome.runtime.sendMessage method: 'login'

  addFields: (canEdit, callback) ->
    return if $('.ap_socializer_extension_fields').length > 0
    console.log 'add fields now'
    $('input.js_taglist-input').attr('tabindex', 3)
    # $('[TabIndex*="5"]').attr('tabindex', -1)
    iconStyle = ''
    textareaStyle = 'class="ap_social_textarea js_taglist-input taglist-input mbn inline-block no-shadow"'
    # $('div.row.editor-actions').after(
    message = ""
    if canEdit
      content =
        """
        <div class="ap_socializer_extension_fields">
          <div style="position: relative;">
            #{message}
            <div class="row collapse ap_social_row">
              <div class="column">
                <span class="js_tag tag">
                  <i class="icon icon-twitter social-icons" #{iconStyle}></i>
                  <div class="js_taglist taglist">
                    <span class="js_taglist-tags taglist-tags mbn no-shadow"></span>
                    <textarea id="tweet-box" #{textareaStyle} type="text" name="tweet" placeholder="Tweet your thoughts" value="" tabindex="4"></textarea>
                    <span class="tweet-char-counter"></span>
                  </div>
                </span>
              </div>
            </div>


            <div class="row collapse ap_social_row ap_social_row_fb">
              <div class="column">
                <span class="js_tag tag">
                  <i class="icon icon-facebook social-icons" #{iconStyle}></i>
                  <div class="js_taglist taglist">
                    <textarea id="ap_facebook-box" #{textareaStyle} type="text" name="tweet" placeholder="Facebook your feelings" value="" tabindex="4"></textarea>
                  </div>
                </span>
              </div>
            </div>
          </div>
        </div>
        """
    else
      content = '<div class="ap_socializer_extension_fields"><h5 class="h5-message">Save your first draft to edit social posts</h5></div>'
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
