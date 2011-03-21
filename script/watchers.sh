#!/bin/sh
cd "$(dirname ${0})/.."
DIR=$(pwd)
coffee --compile --watch public spec &
#stylus --watch public/css &
