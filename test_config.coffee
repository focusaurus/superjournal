config = require './server_config'

exports.configTests = (req, locals) ->
  console.log "BUGBUG config.enableTests is #{config.enableTests}"
  console.log "BUGBUG req.url is #{req.url}"
  path = req.url.slice(0, req.url.indexOf('?'))
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
