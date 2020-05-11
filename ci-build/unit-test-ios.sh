#!/usr/bin/env bash -l

CI_DIRECTORY=$(cd `dirname $0` && pwd)
source "${CI_DIRECTORY}/setup.sh"

echo "============================================="
echo "building and running unit test suite on macOS"
echo "============================================="

xcodebuild \
    -workspace "${PROJECT_NAME}.xcworkspace" \
    -scheme "${PROJECT_NAME}" \
    -destination 'platform=macOS,arch=x86_64' \
    test


