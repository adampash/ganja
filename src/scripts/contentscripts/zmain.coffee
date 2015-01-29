init = ->
  Socializer.init()
  # pageWin = helper.retrieveWindowVariables(['kinja'])
  # if pageWin.kinja? and pageWin.kinja.postMeta?
  #   Socializer.init(pageWin.kinja)
  #   # blogs = {}
  #   # Socializer.getBlogs (_blogs) ->
  #   #   blogs = _blogs
  #   #   console.log blogs
  #   # console.log Socializer.getPublishTime(pageWin.kinja)
  # else
  #   setTimeout ->
  #     init()
  #   , 100

chrome.runtime.onMessage.addListener (request, sender, callback) ->
  if request.method is 'loginComplete'
    Socializer.initEdit()

init()
