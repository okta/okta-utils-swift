#!/usr/bin/env bash -lx

CI_DIRECTORY=$(cd `dirname $0` && pwd)
source "${CI_DIRECTORY}/setup.sh"

echo "============================================="
echo "starting iphone simulator unit test suite"
echo "============================================="

xcodebuild \
    -workspace "${PROJECT_NAME}.xcworkspace" \
    -scheme "${SCHEME_NAME}" \
    -destination 'platform=macOS,arch=x86_64' \
    test


