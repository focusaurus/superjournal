#!/bin/bash
#This is a tasks.sh plug-in script
#These are shared functions any node.js based app might be able to use
########## App (Node.js) Section ##########

#Helper functions
kill_stale() {
    PID_FILE="${PROJECT_DIR}/tmp/server.pid"
    local PID_DIR="$(dirname ${PID_FILE})"
    [ -d "${PID_DIR}" ] || mkdir "${PID_DIR}"
    killpid "${PID_FILE}" "node server"
}

app:prereqs() {
    cdpd
    [ -d tmp ] || mkdir tmp
    cd tmp
    echo "Installing node.js version ${NODE_VERSION}"
    curl --silent --remote-name \
        "http://nodejs.org/dist/node-v${NODE_VERSION}.tar.gz"
    tar xzf node-v${NODE_VERSION}.tar.gz
    cd node-v${NODE_VERSION}
    ./configure  --prefix=~/node && make && make install && make && make install
    cd ..
    rm -rf node-*
    cd ..
    echo "Installing npm"
    #Yes, I know this is a security risk.  I accept the risk. Life is short.
    curl http://npmjs.org/install.sh | sh || exit 4
    echo "Installing npm packages"
    for DEP in $(python "./bin/get_prereqs.py")
    do
        npm install "${DEP}" || exit 5
    done
    echo "Here are the installed npm packages"
    npm list installed
}



app:dev_start() {
    kill_stale
    cdpd
    NODE_ENV=${1-dev} coffee server.coffee &
    echo "$!" > "${PID_FILE}"
    echo "new node process started with pid $(cat ${PID_FILE})"
}

app:dev_stop() {
    kill_stale
}


app:validate() {
    echo "Validating HTML: "
    local ERRORS=0
    for URL in ${@}
    do
        printf '  %-25s' "${URL}: "
        local TMP_HTML="/tmp/tmp_html.$$.html"
        local FETCH_EC=0
        curl --silent "${URL}" --output "${TMP_HTML}" || \
            FETCH_EC=$?
        if [ ${FETCH_EC} -eq 7 ]; then
            echo "SERVER IS NOT RUNNING. ABORTING."
            exit ${FETCH_EC}
        fi
        if [ ${FETCH_EC} -ne 0 ]; then
            echo "FAILED (${FETCH_EC}"
            ERRORS=$((ERRORS + 1))
            continue
        fi
        local VALID_EC=0
        curl --silent "http://validator.w3.org/check" --form \
            "fragment=<${TMP_HTML}" | \
            egrep "was successfully checked as" > /dev/null || VALID_EC=$?
        if [ ${VALID_EC} -ne 0 ]; then
            echo "INVALID"
            ERRORS=$((ERRORS + 1))
        else
            echo "valid"
        fi
        rm "${TMP_HTML}"
    done
    if [ ${ERRORS} -ne 0 ]; then
        echo "ERROR: ${ERRORS} documents are invalid" 1>&2
        exit 5
    else
        echo "SUCCESS: All documents successfully validated"
    fi
}

