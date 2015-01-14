check =
  editorVisible: ->
    $('div.editor:visible').length != 0

  countdown: ->
    140 - 24 - $('#tweet-box').val().length

  getBlogs: ->
    console.log 'getting blogs'
    urls = []
    sites = []
    yourBlogs = $('ul.myblogs .js_ownblog a')
    if yourBlogs.length is 0
      console.log 'no blogs to get'
      return setTimeout =>
        @getBlogs()
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

editing = false

check.getBlogs()

interval = setInterval ->
  unless check.editorVisible() == editing
    editing = check.editorVisible()
    if editing
      view.addFields()
    else
      view.removeFields()
, 500

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
              <span class="tweet-char-counter" style="position: absolute; right: 30px; bottom: 20px;"></span>
            </div>
          </div>
        </div>
        <div class="row" style="border-bottom: rgba(0,0,0,0.3) 1px dashed; margin-top: 10px; padding-top: 10px;">
          <div class="columns medium-12 small-12">
            <div class="columns small-1 medium-1">
              <i class="icon icon-facebook icon-prepend" style="font-size: 25px; margin-top: 12px;" ></i>
            </div>
            <div class="columns medium-11 small-11">
              <textarea class="inline no-shadow" style="color: #000; border: none;" type="text" name="tweet" placeholder="Facebook your feelings" value="" tabindex="7"></textarea>
            </div>
          </div>
        </div>
      """
    )
    $('#tweet-box').on 'keyup', =>
      @setCharCount()
    setTimeout =>
      @setCharCount()
    , 500

  setCharCount: ->
    $('.tweet-char-counter').text check.countdown()

  removeFields: ->
    console.log 'remove fields now'
