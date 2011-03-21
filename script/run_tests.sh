#!/bin/sh
cd $(dirname "${0}")
cd ..
for PAGE in HomePage Layout
do
    echo Testing $PAGE
    jasbin "spec/js/application/${PAGE}Spec.coffee"
done
jasbin "spec/js/unit/EntrySpec.coffee"
find spec -name \*Spec.coffee -print0 | xargs -0 coffee --compile
open -a "Google Chrome" "http://localhost:9500/SpecRunner.html"
