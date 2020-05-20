#!/usr/bin/env bash -l

CI_DIRECTORY=$(cd `dirname $0` && pwd)
source "${CI_DIRECTORY}/setup.sh"

# Main
pushd "${LOGGER_ROOT}"
printBuildEnvironment
set -e
echo "Running pod install..."
pod install

echo "============================================="
echo "building and running unit test suite on macOS"
echo "============================================="

xcodebuild \
    -workspace "${PROJECT_NAME}.xcworkspace" \
    -scheme "${PROJECT_NAME}" \
    -destination 'platform=macOS,arch=x86_64' \
    -derivedDataPath "${DERIVED_DATA}" \
    test
    
# store results / coverage
cp -r "${DERIVED_DATA}"/Logs/Test/*.xcresult "${TEST_RESULTS_DIR}"




