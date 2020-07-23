#!/bin/bash

# Move this to bacon-setup.sh when we opensource
# Setup CI Variables

CI_DIRECTORY=$(cd `dirname $0` && pwd)
source "${CI_DIRECTORY}/setup.sh"
pushd "${LOGGER_ROOT}"

# Main
pushd "${LOGGER_ROOT}"
printBuildEnvironment
# set -e
runTests "$DEVICE_NAME"
if [ $? -ne 0 ]; then
echo "Error running tests"
fi
