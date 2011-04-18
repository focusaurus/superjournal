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

db:dev_stop() {
    cdpd
    killpid tmp/mongod.pid "MongoDB daemon"
}

db:dev_start() {
    db:dev_stop
    cdpd
    [ -d var ] || mkdir var
    mongod --dbpath ./var &
    echo "$!" > tmp/mongod.pid
}

app:test() {
    set -e
    cdpd
    coffee --compile spec bin
    time phantomjs bin/phantom_tests.js --verbose
    rm bin/phantom_tests.js
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

app:debug() {
    node-inspector &
    app:dev_start --nodejs --debug
}
