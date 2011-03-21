#!/bin/sh
cd "$(dirname ${0})/.."
DIR=$(pwd)
find spec -name \*Spec.js -print0 | xargs -0 rm
