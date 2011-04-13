config = require './server_config'
url = require 'url'

exports.configTests = (req, locals) ->
  path = url.parse(req.url).pathname
  if not config.enableTests
    return
  if not req.param 'test'
    return
  switch path
    when '/'
      locals.tests = ['js/application/LayoutSpec.js',
        'js/application/WelcomePageSpec.js']
      if req.session.user
        locals.tests.push 'js/application/HomePageSpec.js'
        locals.tests.push 'js/unit/EntrySpec.js'
