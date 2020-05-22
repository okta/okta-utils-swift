#!/usr/bin/env bash -l

# Constants
PROJECT_NAME="OktaLogger"
LOGGER_ROOT="${CI_DIRECTORY}"/..

DERIVED_DATA="${LOGGER_ROOT}/DerivedData"
if [ -d "${DERIVED_DATA}" ]; then
    rm -rf "${DERIVED_DATA}"
fi

TEST_RESULTS_DIR=${LOGGER_ROOT}/TestResults
if [ ! -d "${TEST_RESULTS_DIR}" ]; then
    mkdir -p "${TEST_RESULTS_DIR}"
fi

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
    if [ -z "$REPO" ] ; then
        GIT_URL=`git remote get-url origin`
        REPO=`basename $GIT_URL .git`
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
}




