########## Global Setup Stuff ##########
baseURL = 'http://localhost:9500'
homePage = baseURL + '/?test=1'
verbose = phantom.args[0] in ["--verbose", "-v"]

########## Shared Helper Functions ##########
out = (message) ->
  if verbose
    console.log '>...' + message

runJasmine = (callback) ->
  if not jasmine?
    console.log 'SuperJournal looks to NOT BE RUNNING. START IT.'
    phantom.exit 15
  jasmine.getEnv().currentRunner().finishCallback = () ->
    runner = jasmine.getEnv().currentRunner()
    results = runner.results()
    output = ['\n']
    if verbose
      for suite in runner.suites()
        output.push suite.description + '\n'
        for spec in suite.specs()
          output.push '  ' + spec.description + '\n'
    if results.skipped
      output.push 'SKIPPED'
    else if results.failedCount == 0
      output.push 'PASS: '
    else
      output.push 'FAIL: '
      countFailure results.failedCount
    output.push "(#{results.passedCount} pass, #{results.failedCount} fail)"
    console.log output.join ''
    callback()
  jasmine.getEnv().execute()

#This is a callback the tests invoke when they finish
runNextTest = ->
  queue = getQueue()
  if queue.length == 0
    #We're done
    out 'DONE'
    phantom.exit getFailureCount()
  else
    openNextURL()

openNextURL = () ->
  testName = getQueue()[0]
  phantom.open testFunctions[testName].URL or homePage

########## State Management Functions ##########
_getState = ->
  if phantom.state
    return JSON.parse phantom.state
  else
    return {failCount: 0, queue: []}

_setState = (state) ->
  out "Saving queue: #{state.queue} with failCount #{state.failCount}"
  phantom.state = JSON.stringify state

getQueue = ->
  return _getState().queue

setQueue = (queue) ->
  state = _getState()
  state.queue = queue
  _setState state
  return queue

countFailure = (count=1) ->
  state = _getState()
  state.failCount += count
  _setState state

getFailureCount = ->
  state = _getState()
  return state.failCount

########## Test Functions ##########
testFunctions = {}
testFunctions.testQueue = (callback, arguments...) ->
  out 'testQueue called with ' + arguments
  callback()

testFunctions.testQueue.URL = 'http://www.bing.com'
testFunctions.testQueue.args = [1, 2, 3]

testFunctions.anonTests = (callback) ->
  out 'running anonymous tests'
  runJasmine callback

testFunctions.signIn = (callback) ->
  out 'logging in'
  $('#email').val 'test@sj.peterlyons.com'
  $('#sign_in_form').submit()
  out 'Just submitted the sign in form as ' + \
    $('input[name=email]').val()
  phantom.sleep 500 #Wait for the sign in to occur
  callback()

testFunctions.signInRedirect = (callback) ->
  out 'signInRedirect called'
  callback()

testFunctions.signedInTests = (callback) ->
  out 'Logged in as: ' + \
    $('#sign_out_form').html().slice(0, 20) + '...'
  runJasmine callback

out('phantom.state is: ' + phantom.state)
switch phantom.state
  when ''
    #populate the initial test queue
    queue = []
    queue.push 'anonTests'
    queue.push 'signIn'
    queue.push 'signInRedirect'
    queue.push 'signedInTests'
    setQueue queue
    #This kicks off the test cycle
    openNextURL()
  else
    #parse the queue JSON
    queue = getQueue()
    test = queue.shift()
    setQueue queue
    testFunc = testFunctions[test]
    URL = testFunc.URL or homePage
    out "Running test function #{test} for URL #{URL} with args #{testFunc.args}"
    args = [runNextTest]
    args.concat testFunc.arguments
    #This actually runs the test
    testFunctions[test].apply window, args
