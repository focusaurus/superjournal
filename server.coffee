util = require 'util'
express = require 'express'

require.paths.unshift '.'
config = require 'server_config'
require.paths.shift()

app = express.createServer()
app.use express.methodOverride()
app.use express.bodyDecoder()
app.use app.router
app.use(require('stylus').middleware({src: __dirname + '/public'}))
app.use express.staticProvider(__dirname + '/public')
app.set 'view engine', 'jade'

app.configure 'test', ()->
  app.use express.staticProvider(__dirname + '/spec')

locals =
  appName: config.appName
  version: config.version

app.get '/', (req, res) ->
  locals.title = "Home"
  res.render 'index', {locals: locals}
  
util.debug "#{config.appName} server starting on port #{config.port}"
app.listen config.port
