#!/bin/sh
cd $(dirname "${0}")
cd ..
for PAGE in HomePage Layout
do
    echo Testing $PAGE
    jasbin "spec/js/application/${PAGE}Spec.coffee"
done
jasbin "spec/js/unit/EntrySpec.coffee"
open -a "Google Chrome" "http://localhost:9500/SpecRunner.html"
