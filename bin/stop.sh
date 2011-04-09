#!/bin/sh
cd "$(dirname ${0})/.."
DIR=$(pwd)
PID_FILE="${DIR}/tmp/node.pid"
if [ -f "${PID_FILE}" ]; then
    echo "killing old node process $(cat ${PID_FILE})"
    kill $(cat "${PID_FILE}") && rm "${PID_FILE}"
fi
