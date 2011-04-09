setup() {
    cd "${TASK_DIR}/.."
    PROJECT_DIR=$(pwd)
    cd - > /dev/null
}

app:test() {
    set -e
    cdpd
    #Due to a zombie issue, we can't run all the tests at once
    for DIR in unit application
    do
        jasbin "spec/js/${DIR}"/*Spec.coffee
    done
    coffee --compile spec
    open -a "Google Chrome" "http://localhost:9500/SpecRunner.html"
}

app:clean() {
    cdpd
    find spec -name \*Spec.js -print0 | xargs -0 rm
}

app:stop_watchers() {
    cdpd
    killpid tmp/watchers.pid "coffee compile watcher"
}

app:start_watchers() {
    app:stop_watchers
    cdpd
    [ -d tmp ] || mkdir tmp
    coffee --compile --watch public spec &
    echo "$!" > tmp/watchers.pid
    #stylus --watch public/css &
}

