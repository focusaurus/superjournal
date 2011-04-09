setup() {
    cd "${TASK_DIR}/.."
    PROJECT_DIR=$(pwd)
    cd -
}

app:test() {
    set -e
    cdpd
    #Due to a zombie issue, we can't run all the tests at once
    for DIR in unit application
    do
        jasbin "spec/js/${DIR}"/*Spec.coffee
    done
    find spec -name \*Spec.coffee -print0 | xargs -0 coffee --compile
    open -a "Google Chrome" "http://localhost:9500/SpecRunner.html"
}

app:clean() {
    cdpd
    find spec -name \*Spec.js -print0 | xargs -0 rm
}
