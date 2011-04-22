describe 'The welcome page', ->
  it "should show a sign in form", ->
    expect($("form input[name=email]")).toBeDefined()
    expect($("form input[type=submit]")).toBeDefined()
