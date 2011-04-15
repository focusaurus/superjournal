console.log('phantom.state is: ' + phantom.state);
if (phantom.state.length === 0) {
    if (phantom.args.length !== 1) {
        console.log('Usage: run-jasmine.js URL');
        phantom.exit();
    } else {
      phantom.state = 'anon-tests'
      phantom.open(phantom.args[0]);
    }
} else if (phantom.state === 'anon-tests') {
    phantom.state = 'user-tests_a';
    $("input[name=email]").val('test@sj.peterlyons.com');
    $('#sign_in_form').submit()
    console.log("Just submitted the signin form as "
      +     $("input[name=email]").val());
    console.log("Waiting for login to complete");
    phantom.sleep(400)
    phantom.open(phantom.args[0]);
} else if (phantom.state === 'user-tests_a') {
    //Craziness here.
    //Need to allow for the server to log the user in
    console.log("Craziness");
    phantom.state = 'user-tests';
    phantom.open(phantom.args[0]);
} else if (phantom.state === 'user-tests') {
  console.log("User tests executing");
  console.log('Logged in as: ' +
    $("#sign_out_form").html().slice(0, 20));
  window.setInterval(function () {
    var list, el, desc, i, j, exitCode;
    exitCode = 0;
    if ($('.finished_at')) {
        console.log(document.body.querySelector('.description').innerText);
        list = document.body.querySelectorAll('div.jasmine_reporter > div.suite.failed');
        for (i = 0; i < list.length; ++i) {
            el = list[i];
            desc = el.querySelectorAll('.description');
            console.log('');
            for (j = 0; j < desc.length; ++j) {
                console.log(desc[j].innerText);
                exitCode += 1;
            }
        }
        phantom.exit(exitCode);
    }
  }, 100);
}

