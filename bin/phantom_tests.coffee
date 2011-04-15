console.log('phantom.state is: ' + phantom.state);
homePage = 'http://localhost:9500/?test=1'
checkJasmine = (nextState, nextURL) ->
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
      console.log "Opening #{nextURL} with state #{nextState}"
      phantom.open nextURL
    else
      phantom.exit exitCode
  else
    console.log 'Jasmine tests did not finish'

runJasmine = (nextState, nextURL) ->
  window.setInterval( ->
    checkJasmine(nextState, nextURL)
  , 100)

switch phantom.state
  when ''
    phantom.state = 'anon_tests'
    phantom.open(homePage);
  when 'anon_tests'
    console.log 'Running anonymous tests'
    runJasmine 'do_log_in', homePage
  when 'do_log_in'
    console.log 'Logging in'
    phantom.state = 'redirect_to_home'
    $('input[name=email]').val 'test@sj.peterlyons.com'
    $('#sign_in_form').submit()
    console.log 'Just submitted the sign in form as ' + \
      $('input[name=email]').val()
    phantom.sleep 500 #Wait for the sign in to occur
    phantom.open homePage
  when 'redirect_to_home'
    #I think this is the 302 Redirect to home
    console.log '302 Redirect to / after successful sign in'
    phantom.state = 'signed_in_tests'
  when 'signed_in_tests'
    console.log 'User tests executing: ' + $('#sign_out_form').html()
    console.log 'Logged in as: ' + \
      $('#sign_out_form').html().slice(0, 20)
    runJasmine()
