@config =
  dev: false
  socializer_url: ->
    if @dev then "http://localhost:3000" else "https://gawker-socializer.herokuapp.com"
  whos_editing_url: ->
    if @dev then "http://localhost:3001" else "tbd"
