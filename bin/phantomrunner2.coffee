if not phantom.state.length
  phantom.state = 'run-tests'
  phantom.open 'http://localhost:9500/?test=1'
else
  jasmine.getEnv().currentRunner().finishCallback = () ->
    results = jasmine.getEnv().currentRunner().results()
    console.log "Passed: " + results.passedCount
    console.log "Failed: " + results.failedCount
    phantom.exit 0
  jasmine.getEnv().execute()
