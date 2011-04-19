_ = require 'underscore'
config = require './server_config'
express = require 'express'
mongoose = require 'mongoose'
tests = require './test_config'
url = require 'url'

########## Mongoose Setup ##########
toLower = (v) ->
  v.toLowerCase()

#Define mongoose/mongodb schemas
UserSchema = new mongoose.Schema(
  email: { type: String, index: true, set: toLower }
)

EntrySchema = new mongoose.Schema(
  content: String
  createdOn: Number
  tags: [String]
  author: mongoose.Schema.Types.ObjectId
)

mongoose.model 'User', UserSchema
mongoose.model 'Entry', EntrySchema
User = mongoose.model 'User'
Entry = mongoose.model 'Entry'

mongoose.connect config.db.URL

########## Express Setup ##########

#Note requireUser is not currently used, but might be useful in the future
requireUser = (req, res, next) ->
  #urlObj = url.parse req.url
  #if urlObj.pathname in ['/', '/signin', '/favicon.ico']
  #  #The welcome page can be accessed anonymously
  #  return next()
  #else
  if req.session and req.session.user
    #We have a user, proceed with middleware
    next()
  else
    #Force a sign in
    #TODO, remember what the desired URL was and go there after sign in
    console.log 'BUGBUG requireUser redirecting for: ' + urlObj.pathname
    res.redirect '/'

requireAPIUser = (req, res, next) ->
  if req.session and req.session.user
    next()
  else
    res.header 'Content-Type', 'application/json'
    res.send 'You must log in to access this API', 403

app = express.createServer()

app.error (error, req, res, next) ->
  console.log 'BUGBUG error: ' + error
  console.log req.url
  next(error)

#DANGER.  The order of these app.use calls is highly sensitive.
#Don't futz with it.
#PL Note to self. express.bodyParser must come very early. Not sure why.
#Otherwise AJAX requests hang
app.use express.bodyParser()

config.env[process.env.NODE_ENV or 'development'] = true
#In staging in production, listen loopback. nginx listens on the network.
ip = '127.0.0.1'
if process.env.NODE_ENV not in ['production', 'staging']
  config.enableTests = true
  #Note: turn this on as needed. Keep it off normally because it floods.
  #DISABLED#app.use express.logger()
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
  #Serve up the jasmine SpecRunner.html file
  app.use express.static(__dirname + '/spec')
  #Listen on all IPs in dev/test (for testing from other machines)
  ip = '0.0.0.0'
app.use express.cookieParser()
app.use express.session secret: "SuperJournaling asoetuhasoetuhas"
#Note to self. static comes BEFORE stylus or plain .css won't work
app.use express.static(__dirname + '/public')
app.use(require('stylus').middleware({src: __dirname + '/public'}))
app.set 'view engine', 'jade'
#app.use requireUser

defaultLocals =
  appName: config.appName
  version: config.version
  tests: false

app.get '/', (req, res) ->
  locals = _.defaults({title: "Home", user: req.session.user}, defaultLocals)
  tests.configTests req, locals
  if not req.session.user
    locals.title = 'Sign In'
    locals.config = config
    res.render 'signin', {locals: locals}
  else
    res.render 'index', {locals: locals}

doneLogin = (req, res, user) ->
  req.session.user = user
  console.log "You are now logged in as #{req.session.user.email} #{user._id}"
  res.redirect '/'

app.post '/signin', (req, res) ->
  email = (req.body.user.email or '').toLowerCase()
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

app.get '/entries', requireAPIUser, (req, res) ->
  Entry.find {author: req.session.user._id}, (error, entries) ->
    if error
      res.send 500, error.toString()
      return
    res.header('Content-Type', 'application/json');
    res.send JSON.stringify(entries)

app.post '/entries', requireAPIUser, (req, res) ->
    entry = new Entry(
      content: req.body.content
      createdOn: new Number(req.body.createdOn)
      author: req.session.user._id)
    entry.save (error) ->
      if error
        res.send error, 500
        return
      res.send entry
      return

app.put '/entries/:id', requireAPIUser, (req, res) ->
  entry = Entry.findById req.params.id, (error, entry) ->
    if error
      res.send error, 500
      return
    else if entry
      if req.session.user._id != entry.author.toString()
        res.header 'Content-Type', 'application/json'
        res.send "You do not have access to this entry", 403
        return
      entry.content = req.body.content
      entry.save (error) ->
        if error
          res.send error, 500
          return
        res.send entry.toJSON()
        return
    else
      res.send 404
      return

app.get '/entries/:id', requireAPIUser, (req, res) ->
  #TODO filtering by user
  Entry.findById req.params.id, (error, entry) ->
    if error
      res.send 500, error.toString()
      return
    res.send entry.toJSON()

app.del '/entries/:id', requireAPIUser, (req, res) ->
  console.log 'DELETE came in to /entries for ' + req.params.id
  Entry.findById req.params.id, (error, entry) ->
    if error
      res.send 500, error.toString()
      return
    #TODO filtering by user (Need tests for this)
    if req.session.user._id != entry.author
      res.header 'Content-Type', 'application/json'
      res.send 403
      return
    entry.remove (error) ->
      if error
        res.send error, 500
        return
      res.send 200


console.log "#{config.appName} server starting on http://#{ip}:#{config.port}"
app.listen config.port, ip
