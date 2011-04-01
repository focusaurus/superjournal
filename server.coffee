util = require 'util'
express = require 'express'

config = require './server_config'

app = express.createServer()
app.use express.methodOverride()
app.use express.bodyParser()
app.use app.router
#Note to self. static comes BEFORE stylus or plain .css won't work
app.use express.static(__dirname + '/public')
app.configure 'test', ()->
  app.use express.static(__dirname + '/spec')
app.use(require('stylus').middleware({src: __dirname + '/public'}))
app.set 'view engine', 'jade'



locals =
  appName: config.appName
  version: config.version

app.get '/', (req, res) ->
  locals.title = "Home"
  res.render 'index', {locals: locals}
  
util.debug "#{config.appName} server starting on port #{config.port}"
app.listen config.port
