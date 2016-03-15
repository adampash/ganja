@Dispatcher = _.clone(Backbone.Events)

init = ->
  Socializer.init()
  # ContactInfo.init()
  Utils.init()
  WordCount.init()

chrome.runtime.onMessage.addListener (request, sender, callback) ->
  if request.method is 'loginComplete'
    Socializer.initEdit()

init()
