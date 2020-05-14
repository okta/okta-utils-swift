#!/usr/bin/env bash -lx

CI_DIRECTORY=$(cd `dirname $0` && pwd)
source "${CI_DIRECTORY}/setup.sh"

# Main
set -e
pushd "${LOGGER_ROOT}"
printBuildEnvironment
echo "Running pod install..."
pod install

echo "============================================="
echo "building and running unit test suite on macOS"
echo "============================================="

xcodebuild \
    -workspace "${PROJECT_NAME}.xcworkspace" \
    -scheme "${PROJECT_NAME}" \
    -destination 'platform=macOS,arch=x86_64' \
    test


