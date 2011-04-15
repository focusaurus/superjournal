#out('phantom.state is: ' + phantom.state);
homePage = 'http://localhost:9500/?test=1'
errorCount = 0
verbose = phantom.args[0] in ["--verbose", "-v"]
metaPrompt = '>...'
out = (message) ->
  console.log metaPrompt + message

checkJasmineDOM = (nextState, nextURL) ->
  if $('.finished_at')
    exitCode = 0
    console.log $('.description').text()
    $('div.jasmine_reporter > div.suite.failed').each (index, item) ->
      console.log ''
      desc = $(item).find('.description').each (index2, item2) ->
        console.log $(item2).text()
        exitCode += 1
    if nextURL
      phantom.state = nextState
      #console.log "Opening #{nextURL} with state #{nextState}"
      phantom.open nextURL
    else
      phantom.exit exitCode
  else
    console.log 'Jasmine tests did not finish'

checkJasmineJS = (nextState, nextURL) ->
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
    output.push "(#{results.passedCount} pass, #{results.failedCount} fail)"
    errorCount += results.failedCount
    console.log output.join ''
    if nextURL
      phantom.state = nextState
      #out "Opening #{nextURL} with state #{nextState}"
      phantom.open nextURL
    else
      phantom.exit errorCount
  jasmine.getEnv().execute()

runJasmine = (nextState, nextURL) ->
  window.setInterval( ->
    checkJasmineJS(nextState, nextURL)
  , 100)



switch phantom.state
  when ''
    phantom.state = 'anon_tests'
    phantom.open(homePage);
  when 'anon_tests'
    out 'running anonymous tests'
    runJasmine 'do_log_in', homePage
  when 'do_log_in'
    #out 'logging in'
    phantom.state = 'redirect_to_home'
    $('input[name=email]').val 'test@sj.peterlyons.com'
    $('#sign_in_form').submit()
    #out 'Just submitted the sign in form as ' + \
    #  $('input[name=email]').val()
    phantom.sleep 500 #Wait for the sign in to occur
    phantom.open homePage
  when 'redirect_to_home'
    #I think this is the 302 Redirect to home
    #out '302 Redirect to / after successful sign in'
    phantom.state = 'signed_in_tests'
  when 'signed_in_tests'
    out 'Logged in as: ' + \
      $('#sign_out_form').html().slice(0, 20) + '...'
    runJasmine()
