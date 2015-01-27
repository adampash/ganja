(function() {
  var saveSocial, updatePublishTime;

  chrome.runtime.onInstalled.addListener(function(details) {
    return console.log('previousVersion', details.previousVersion);
  });

  chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
    if (request) {
      console.log(sender.tab ? "from a content script:" + sender.tab.url : "from the extension");
      if (request.method === "saveSocial") {
        delete request.method;
        return saveSocial(request);
      } else if (request.method === "updatePublishTime") {
        delete request.method;
        return updatePublishTime(request);
      }
    }
  });

  saveSocial = function(params) {
    console.log('saving social!');
    params.publish_at = new Date(params.publish_at);
    console.log(params);
    return $.ajax({
      url: "http://localhost:3000/stories",
      method: "POST",
      data: params,
      success: (function(_this) {
        return function(data) {
          return console.log('saved posts', data);
        };
      })(this),
      error: function() {
        return console.log('something went wrong saving this');
      }
    });
  };

  updatePublishTime = function(params) {
    console.log('updating publish time');
    params.publish_at = new Date(params.publish_at);
    console.log(params);
    return $.ajax({
      url: "http://localhost:3000/stories",
      method: "POST",
      data: params,
      success: (function(_this) {
        return function(data) {
          return console.log('saved posts', data);
        };
      })(this),
      error: function() {
        return console.log('something went wrong saving this');
      }
    });
  };

  console.log('\'Allo \'Allo! Event Page');

}).call(this);

//# sourceMappingURL=background.js.map
