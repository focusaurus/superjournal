#Called by tasks.sh to initialize key variables
setup() {
    cd "${TASK_DIR}/.."
    PROJECT_DIR=$(pwd)
    cd - > /dev/null
}

mktmp() {
    cdpd
    [ -d tmp ] || mkdir tmp
    cd -
}

os:prereqs() {
    case $(uname) in
        Darwin)
            #Install phantom js
            sudo port selfupdate
            sudo port install phantomjs
            sudo port install mongodb
        ;;
        Linux)
        ;;
    esac
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
    phantomjs bin/run-jasmine.js "http://localhost:9500/SpecRunner.html"
}

app:clean() {
    cdpd
    find spec -name \*Spec.js -print0 | xargs -0 rm
}

app:stop_watchers() {
    cdpd
    killpid tmp/watchers.pid "coffee compile watcher"
    killpid tmp/watchers.pid "stylus compile watcher"
}

app:start_watchers() {
    app:stop_watchers
    cdpd
    mktmp
    coffee --compile --watch public spec &
    echo "$!" > tmp/coffee.pid
    stylus --watch public/css &
    echo "$!" > tmp/stylus.pid
}

