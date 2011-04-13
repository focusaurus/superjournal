util = require 'util'
express = require 'express'
_ = require 'underscore'
config = require './server_config'
tests = require './test_config'

app = express.createServer()

#In staging in production, listen loopback. nginx listens on the network.
ip = '127.0.0.1'
if process.env.NODE_ENV not in ['production', 'staging']
  config.enableTests = true
  app.use express.logger()
  #Serve up the jasmine SpecRunner.html file
  app.use express.static(__dirname + '/spec')
  #Listen on all IPs in dev/test (for testing from other machines)
  ip = '0.0.0.0'
app.use express.methodOverride()
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session secret: "SuperJournaling asoetuhasoetuhas"
app.use app.router
#Note to self. static comes BEFORE stylus or plain .css won't work
app.use express.static(__dirname + '/public')
app.use(require('stylus').middleware({src: __dirname + '/public'}))
app.set 'view engine', 'jade'

defaultLocals =
  appName: config.appName
  version: config.version
  tests: false

app.get '/', (req, res) ->
  locals = _.defaults({title: "Home", user: req.session.user}, defaultLocals)
  tests.configTests req, locals
  if not req.session.user
    locals.title = 'Sign In'
    res.render 'signin', {locals: locals}
  else
    res.render 'index', {locals: locals}

app.post '/signin', (req, res) ->
  req.session.user = req.param 'email'
  console.log "You are now logged in as #{req.session.user}"
  res.redirect '/'

app.post '/signout', (req, res) ->
  req.session.user = null
  res.redirect '/'

util.debug "#{config.appName} server starting on http://#{ip}:#{config.port}"
app.listen config.port, ip

