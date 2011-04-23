#Called by tasks.sh to initialize key variables
setup() {
    cd "${TASK_DIR}/.."
    PROJECT_DIR=~/projects/superjournal
    REPO_URL=ssh://git.peterlyons.com/home/plyons/projects/superjournal.git
    BRANCH=master
    NODE_VERSION=0.4.3
    STAGING_HOSTS=sj.peterlyons.com
    export PATH=~/node/bin:$PATH
    cd - > /dev/null
}

mktmp() {
    cdpd
    [ -d tmp ] || mkdir tmp
    cd -
}

os:prereqs() { #TASK: sudo
    case $(uname) in
        Darwin)
            #Install phantom js
            sudo port selfupdate
            sudo port install phantomjs
            sudo port install mongodb
        ;;
        Linux)
            DEBS='#Needed to download node and npm
curl
#Needed to build node.js
g++
#Source Code Management
git-core
#Needed to build node.js with SSL support
libssl-dev
#Needed to build node.js
make
#For monitoring
monit
#This is our web server
nginx
'
            apt_install "${DEBS}"
        ;;
    esac
}

os:initial_setup() { #TASK: sudo
    os:prereqs
}

scm:initial_setup() {
    scm:clone
}

app:initial_setup() {
    app:prereqs
}

db:initial_setup() { #TASK: sudo
    #MongoDB install
    apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
    echo \
      "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" \
      >>/etc/apt/sources.list
    apt-get update
    apt-get install mongodb-10gen
}

db:dev_stop() {
    cdpd
    killpid tmp/mongod.pid "MongoDB daemon"
}

db:dev_start() {
    db:dev_stop
    cdpd
    [ -d var ] || mkdir var
    mongod --dbpath ./var --port 9501 &
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
    cdpd
    killpid  tmp/node-inspector.pid
    node-inspector &
    echo "$!" > tmp/node-inspector.pid
    kill_stale
    NODE_ENV=${1-development} coffee --nodejs --debug server.coffee &
    echo "$!" > "${PID_FILE}"
    echo "new node process started with pid $(cat ${PID_FILE})"
}

