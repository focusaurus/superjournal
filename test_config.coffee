config = require './server_config'
url = require 'url'

exports.configTests = (req, locals) ->
  if not config.enableTests
    return
  if not req.param 'test'
    return
  path = url.parse(req.url).pathname
  switch path
    when '/'
      locals.tests = ['js/application/LayoutSpec.js']
      if req.session.user
        locals.tests.push 'js/application/HomePageSpec.js'
        locals.tests.push 'js/unit/EntrySpec.js'
        locals.tests.push 'js/application/RESTAPIUserSpec.js'
      else
        locals.tests.push 'js/application/WelcomePageSpec.js'
        locals.tests.push 'js/application/RESTAPIAnonSpec.js'
