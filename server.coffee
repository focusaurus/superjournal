util = require 'util'
express = require 'express'
_ = require 'underscore'
config = require './server_config'

app = express.createServer()

#In staging in production, listen loopback. nginx listens on the network.  
ip = '127.0.0.1'
if process.env.NODE_ENV not in ['production', 'staging']
  app.use express.logger()
  #Serve up the jasmine SpecRunner.html file
  app.use express.static(__dirname + '/spec')
  #Listen on all IPs in dev/test (for testing from other machines)
  ip = '0.0.0.0'
app.use express.methodOverride()
app.use express.bodyParser()
app.use app.router
#Note to self. static comes BEFORE stylus or plain .css won't work
app.use express.static(__dirname + '/public')
app.use(require('stylus').middleware({src: __dirname + '/public'}))
app.set 'view engine', 'jade'

defaultLocals =
  appName: config.appName
  version: config.version

app.get '/', (req, res) ->
  locals = _.defaults({title: "Home"}, defaultLocals)
  res.render 'index', {locals: locals}

util.debug "#{config.appName} server starting on http://#{ip}:#{config.port}"
app.listen config.port, ip

