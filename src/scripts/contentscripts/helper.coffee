helper =
  retrieveWindowVariables: (variables) ->
    ret = {}

    scriptContent = ""
    for currVariable in variables
      scriptContent += "if (typeof " + currVariable + " !== 'undefined') document.body.setAttribute('tmp_" + currVariable + "', JSON.stringify(" + currVariable + "));\n"

    script = document.createElement('script')
    script.id = 'tmpScript'
    script.appendChild(document.createTextNode(scriptContent))
    (document.body || document.head || document.documentElement).appendChild(script)

    for currVariable in variables
      ret[currVariable] = JSON.parse $("body").attr("tmp_" + currVariable)
      $("body").removeAttr("tmp_" + currVariable)

    $("#tmpScript").remove()

    ret

  watchAjax: (callback) ->
    scriptContent = """
      setTimeout(function() {
      $(document).ajaxSuccess(function() {
        debugger;
        $( ".log" ).text( "Triggered ajaxSuccess handler." );
      });
      }, 1000);
      """
    script = document.createElement('script')
    script.id = 'ajaxSuccess'
    script.appendChild(document.createTextNode(scriptContent))
    (document.body || document.head || document.documentElement).appendChild(script)
