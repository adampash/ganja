dev = false

if dev
  root = "http://localhost:3000"
else
  root = "http://gawker-socializer.herokuapp.com"

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
      else if request.method is "login"
        login(sender.tab)

loginTab = {}
senderTab = null
loginCallback = null
login = (_senderTab) ->
  senderTab = _senderTab
  chrome.tabs.create
    windowId: null
    url: "#{root}/signin"
    index: senderTab.index + 1
    , (_tab) ->
      loginTab = _tab
  chrome.tabs.onRemoved.addListener tabClosed
  chrome.tabs.onUpdated.addListener tabUpdated

tabUpdated = (tabId, changeInfo, tab) ->
  if tabId is loginTab.id
    closeTab(tab, tabId, senderTab)

closeTab = (tab, tabId, senderTab) ->
  if tab.url.match /^http:\/\/(localhost:3000|gawker-socializer.herokuapp.com)\/login_success/
    console.log 'now close the tab and go back to editor'
    chrome.tabs.remove(tabId)
    chrome.tabs.update(senderTab.id, active: true)
    chrome.tabs.onUpdated.removeListener tabUpdated

tabClosed = (tabId, removeInfo) ->
  console.log 'running tabClosed'
  if tabId = loginTab.id
    loginTab = {}
    console.log 'it is the right tab'
    chrome.tabs.sendMessage(senderTab.id, method: 'loginComplete')
    removeListener()

removeListener = ->
  chrome.tabs.onRemoved.removeListener tabClosed

saveSocial = (params) ->
  console.log 'saving social!'
  params.publish_at = new Date(params.publish_at)
  console.log params
  $.ajax
    url: "#{root}/stories"
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
    url: "#{root}/stories/update_pub"
    method: "POST"
    data: params
    success: (data) =>
      console.log 'saved posts', data
    error: ->
      console.log 'something went wrong saving this'

console.log('\'Allo \'Allo! Event Page');
