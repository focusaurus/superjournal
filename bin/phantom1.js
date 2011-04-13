if (phantom.state.length === 0) {
    if (phantom.args.length !== 1) {
        console.log('Usage: run-jasmine.js URL');
        phantom.exit();
    } else {
        phantom.state = 'run-jasmine';
        phantom.open(phantom.args[0]);
    }
} else {
    $('head').append("<script type='text/javascript' src='lib/jasmine/jasmine.js'></script>");
    $('head').append("<script type='text/javascript' src='js/unit/EntrySpec.js'></script>");
    describe('phantom and jasmine', function() {
        console.log("Describe is running");
        it('should work together', function() {
            console.log("it is running");
            expect(0).toEqual(0);
        });

    });
    jasmine.getEnv().execute();
    jasmine.getEnv().currentRunner().finishCallback = function() {
      results = jasmine.getEnv().currentRunner().results();
      console.log("Passed: " + results.passedCount);
      console.log("Failed: " + results.failedCount);
      phantom.exit(0);
    };

}
