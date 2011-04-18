_ = require 'underscore'
config = require './server_config'
express = require 'express'
mongoose = require 'mongoose'
tests = require './test_config'

#Define mongoose/mongodb schemas
toLower = (v) ->
  v.toLowerCase()
UserSchema = new mongoose.Schema(
  email: { type: String, index: true, set: toLower }
)
EntrySchema = new mongoose.Schema(
  content: String
  createdOn: Number
  tags: [String]
  #author: mongoose.ObjectId
)

mongoose.model 'User', UserSchema
mongoose.model 'Entry', EntrySchema
User = mongoose.model 'User'
Entry = mongoose.model 'Entry'

mongoose.connect config.db.URL
app = express.createServer()

#In staging in production, listen loopback. nginx listens on the network.
ip = '127.0.0.1'
if process.env.NODE_ENV not in ['production', 'staging']
  config.enableTests = true
  app.use express.logger()
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
  #Serve up the jasmine SpecRunner.html file
  app.use express.static(__dirname + '/spec')
  #Listen on all IPs in dev/test (for testing from other machines)
  ip = '0.0.0.0'
#PL Note to self. express.bodyParser breaks AJAX/JSON. DO NOT USE
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session secret: "SuperJournaling asoetuhasoetuhas"
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

doneLogin = (req, res, user) ->
  req.session.user = user
  console.log "You are now logged in as #{req.session.user.email} #{user._id}"
  res.redirect '/'

requireUser = (req, res, next) ->
  if req.session.user then  next() else res.redirect '/'

app.post '/signin', (req, res) ->
  email = (req.param('email') or '').toLowerCase()
  User.findOne {email: email}, (error, user) ->
    if user
      doneLogin req, res, user
    else
      newUser = new User {email: email}
      newUser.save (error)->
        if error
          res.send "Problem creating your user account #{error}", 500
          return
        doneLogin req, res, newUser

app.post '/signout', (req, res) ->
  req.session.user = null
  res.redirect '/'

app.post '/entries', requireUser, (req, res) ->
  console.log 'POST came in to /entries'
  console.log req.body
  entry = new Entry(
    content: req.body.content
    createdOn: new Number(req.body.createdOn))
  entry.save (error) ->
    if error
      res.send error, 500
      return
    res.send entry

app.get '/entries/:id', requireUser, (req, res) ->
  #TODO filtering by user
  Entry.findById req.params.id, (error, entry) ->
    if error
      res.send 500, error.toString()
      return
    res.send entry.toJSON()

app.del '/entries/:id', requireUser, (req, res) ->
  console.log 'DELETE came in to /entries'
  #TODO filtering by user
  Entry.findById req.params.id, (error, entry) ->
    if error
      res.send 500, error.toString()
      return
    entry.remove (error) ->
      res.send 200

console.log "#{config.appName} server starting on http://#{ip}:#{config.port}"
app.listen config.port, ip
