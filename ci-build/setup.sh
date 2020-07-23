#!/bin/bash

# Constants
PROJECT_NAME="OktaLogger"
LOGGER_ROOT="${CI_DIRECTORY}"/..

DERIVED_DATA="${LOGGER_ROOT}/DerivedData"
if [ -d "${DERIVED_DATA}" ]; then
    rm -rf "${DERIVED_DATA}"
fi


# Common environment variables
FASTLANE_DIRECTORY="$WORKSPACE/${REPO}/fastlane"
LOGDIRECTORY=$HOME/dart
# Echos an error message
function echoError() {
  RED='\033[0;31m'
  NOCOLOR='\033[0m' #Default
  printf "${RED}${1}${NOCOLOR}\n"
  exit 1
}

# Echos a success message
function echoSuccess() {
  GREEN='\033[0;32m'
  NOCOLOR='\033[0m' #Default
  printf "${GREEN}${1}${NOCOLOR}\n"
}

function runTests() {
  echo "===================="
  echo "simulator test"
  echo "===================="
  xcodebuild -version
  pwd

  ## Perform basic setup
  # Setup environment vars
  FASTLANE_TEST_RESULTS_DIR="$FASTLANE_DIRECTORY/test_output"
  TEST_RESULT_FILE="test-result.xml"
  FASTLANE_TEST_RESULTS_FILE="${FASTLANE_TEST_RESULTS_DIR}/${TEST_RESULT_FILE}"

  # Truncated directory to tell dart where test results are
  DART_TEST_RESULTS_DIR="${REPO}/OktaLogger/fastlane/test_output"

  # Clean out old test results
  if [ -d "$FASTLANE_TEST_RESULTS_DIR" ]; then
    echo "Removing: $FASTLANE_TEST_RESULTS_DIR"
    rm -rf "$FASTLANE_TEST_RESULTS_DIR"
  fi

  if [ -d "$DART_TEST_RESULTS_DIR" ]; then
    echo "Removing: $DART_TEST_RESULTS_DIR"
    rm -rf "$DART_TEST_RESULTS_DIR"
  fi

  if [ -f "${LOGDIRECTORY}/${TEST_RESULT_FILE}" ]; then
    echo "Removing: ${LOGDIRECTORY}/${TEST_RESULT_FILE}"
    rm -f "${LOGDIRECTORY}/${TEST_RESULT_FILE}"
  fi

  export TEST_SUITE_TYPE="junit"
  export TEST_RESULT_FILE_DIR="${DART_TEST_RESULTS_DIR}"

  echo $TEST_SUITE_TYPE > $TEST_SUITE_TYPE_FILE
  echo $TEST_RESULT_FILE_DIR > $TEST_RESULT_FILE_DIR_FILE

  bundle exec fastlane test device:"$1"

  FOUND_ERROR=$?

  ### Send xml up to logs dir
  echo "CI-INFO: Copying Test Results XML to $LOGDIRECTORY"
  if [ -f $FASTLANE_TEST_RESULTS_FILE ]; then
    cp $FASTLANE_TEST_RESULTS_FILE $LOGDIRECTORY
  else
    # files are not collated ? 
    find $FASTLANE_TEST_RESULTS_DIR -name "*.xml" -exec cp {} ${LOGDIRECTORY} \;
  fi 
  echo "CI-INFO: Archiving Test Results to $LOGDIRECTORY"
  tar zcvf "${LOGDIRECTORY}/testResults.tar.gz" -C $FASTLANE_DIRECTORY test_output 
  realpath ${LOGDIRECTORY}/testResults.tar.gz
  ls -l ${LOGDIRECTORY}/testResults.tar.gz
  ### Failure! One or other test suites exit non-zero
  if [ "$FOUND_ERROR" -ne 0 ] ; then
    echo "error: $FOUND_ERROR"
    return 1
  fi

  # Success!
  return 0
}

function runSwiftLint() {
  LINT_RESULTS_DIR="${FASTLANE_DIRECTORY}/lint"

  # Clean out old test results
  if [ -d "$LINT_RESULTS_DIR" ]; then
    echo "Removing: $LINT_RESULTS_DIR"
    rm -rf "$LINT_RESULTS_DIR"
  fi

  bundle exec fastlane lint action:$1
  LINT_ERROR=$?
  echo "CI-INFO: Copy Lint output to $LOGDIRECTORY"
  cp $LINT_RESULTS_DIR/* $LOGDIRECTORY

  if [ "$LINT_ERROR" -ne 0 ]; then
	echo "error: $LINT_ERROR"
	return 1
  fi
}

# Print header with build machine, build launch information
function printBuildEnvironment() {
    USER=`whoami`
    HOST_NAME=`hostname`
    HOST_IP=`ifconfig en0 | grep inet | grep -v inet6 | awk '{print $2}'`
    OS_NAME=`sw_vers -productName`
    OS_VERSION=`sw_vers -productVersion`
    XCODE_VERSION=`xcodebuild -version | head -1 | awk '{print $2}'`
    RUBY_VERSION=`ruby -v | awk {'print $2'}`
    TIME_NOW=`date`
    UPTIME=`uptime`
    QUEUE=${SQS_QUEUE_URL}
    if [ -z "$SHA" ] ; then
        SHA=`git rev-parse  HEAD 2> /dev/null`
    fi
    if [ -z "$BRANCH" ] ; then
        BRANCH=`git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1/"`
    fi
    AUTHOR=`git show -s --pretty='%an'`
    COMMIT=`git show -s --pretty='%s'`
    COMMIT_DATE=`git show -s --pretty='%aD'`
    echo "====================================================="
    echo " Build  Launch"
    echo ""
    echo "  Time: $TIME_NOW"
    echo "Script: $SCRIPTNAME"
    echo "  Repo: $REPO"
    echo "Branch: $BRANCH"
    echo "   SHA: $SHA"
    echo "Author: $AUTHOR"
    echo "  Date: $COMMIT_DATE"
    echo "Commit: $COMMIT"
    echo "====================================================="
    echo " Build  Environment"
    echo ""
    echo "  Host: $HOST_NAME [$HOST_IP]"
    echo " Queue: $QUEUE"
    echo "  User: $USER"
    echo "    OS: $OS_NAME $OS_VERSION"
    echo " Xcode: $XCODE_VERSION"
    echo "  ruby: $RUBY_VERSION"
    echo "uptime: $UPTIME"
    echo "====================================================="
    echo "====================================================="
    echo " Test Details"
    echo "Device: "  $DEVICE_NAME
    echo "Test: "  $TEST_GROUP
    echo "====================================================="
}
