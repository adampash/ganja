chrome.runtime.onInstalled.addListener (details) ->
  console.log('previousVersion', details.previousVersion)

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  if request
      console.log(if sender.tab then "from a content script:" + sender.tab.url else "from the extension")
      if request.method is "saveSocial"
        delete request.method
        saveSocial(request)
      else if request.method is "updatePublishTime"
        delete request.method
        updatePublishTime(request)
        # sendResponse({farewell: "goodbye"})

saveSocial = (params) ->
  console.log 'saving social!'
  params.publish_at = new Date(params.publish_at)
  console.log params
  $.ajax
    url: "http://localhost:3000/stories"
    method: "POST"
    data: params
    success: (data) =>
      console.log 'saved posts', data
    error: ->
      console.log 'something went wrong saving this'

updatePublishTime = (params) ->
  console.log 'updating publish time'
  params.publish_at = new Date(params.publish_at)
  console.log params
  $.ajax
    url: "http://localhost:3000/stories/update_pub"
    method: "POST"
    data: params
    success: (data) =>
      console.log 'saved posts', data
    error: ->
      console.log 'something went wrong saving this'

console.log('\'Allo \'Allo! Event Page');
