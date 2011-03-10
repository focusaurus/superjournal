express = require('express')
util = require('util')

locals = 
  appName: "SuperJournal"
  version: "0.0.1"
  
exports.appName = locals.appName
exports.version = locals.version
exports.port = 9500

app = express.createServer()
app.configure ->
  app.use express.methodOverride()
  app.use express.bodyDecoder()
  app.use app.router
  app.use(require('stylus').middleware({src: __dirname + '/public'}))
  app.use express.staticProvider(__dirname + '/public')

app.set 'view engine', 'jade'

app.get '/', (req, res) ->
  locals.title = "Home"
  res.render 'index', {locals: locals}
  
util.debug "#{locals.appName} server starting on port #{exports.port}"
app.listen exports.port
