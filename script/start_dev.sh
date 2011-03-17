#!/bin/sh
cd "$(dirname ${0})/.."
DIR=$(pwd)
PID_FILE="${DIR}/tmp/node.pid"
PID_DIR="$(dirname ${PID_FILE})"
if [ ! -d "${PID_DIR}" ]; then
    mkdir "${PID_DIR}"
fi
if [ -f "${PID_FILE}" ]; then
    echo "killing old node process $(cat ${PID_FILE})"
    kill $(cat "${PID_FILE}")
fi
coffee server.coffee &
echo "$!" > "${PID_FILE}"
echo "new node process started with pid $(cat ${PID_FILE})"
sleep 2
open -a "Google Chrome" http://localhost:9500
