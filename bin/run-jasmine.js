if (phantom.state.length === 0) {
    if (phantom.args.length !== 1) {
        console.log('Usage: run-jasmine.js URL');
        phantom.exit();
    } else {
      phantom.state = 'anon-tests'
      phantom.open(phantom.args[0]);
    }
} else if (phantom.state === 'anon-tests') {
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
            window.clearInterval();
            phantom.state = 'user-tests';
            $("input[name=email]").val('test@sj.peterlyons.com');
            $('#sign_in_form').submit()
        }
    }, 100);
} else if (phantom.state === 'user-tests') {
  console.log("User tests executing");
}

