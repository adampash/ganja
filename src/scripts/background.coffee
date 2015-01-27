chrome.runtime.onInstalled.addListener (details) ->
  console.log('previousVersion', details.previousVersion)

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  if request
      console.log(if sender.tab then "from a content script:" + sender.tab.url else "from the extension")
      if (request.method == "saveSocial")
        delete request.method
        saveSocial(request)
        # sendResponse({farewell: "goodbye"})

saveSocial = (params) ->
  console.log 'saving social!'
  $.ajax
    url: "http://localhost:3000/stories"
    method: "POST"
    data: params
    success: (data) =>
      console.log 'saved posts', data
    error: ->
      console.log 'something went wrong saving this'

console.log('\'Allo \'Allo! Event Page');
