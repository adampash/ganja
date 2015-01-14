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
