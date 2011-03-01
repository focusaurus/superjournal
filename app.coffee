locals = 
  appName: "SuperJournal"
  version: "0.0.1"
express = require('express')
util = require('util')
#coffeekup = require('coffeekup')
app = express.createServer()
app.configure ->
  app.use express.methodOverride()
  app.use express.bodyDecoder()
  app.use app.router
  app.use(require('stylus').middleware({src: __dirname + '/public'}))
  #app.use(express.compiler
  #  src: __dirname + '/public'
  #  enable: ['less']
  #  )
  app.use express.staticProvider(__dirname + '/public')

#app.register '.coffee', coffeekup
app.set 'view engine', 'jade'
#app.set 'view options', {format: true, cache: false}

app.get '/', (req, res) ->
  locals.title = "Home"
  res.render 'index', {locals: locals}
  
port = 9500
util.debug "#{locals.appName} server starting on port #{port}"
app.listen port
