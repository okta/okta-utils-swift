#!/usr/bin/env bash -lx

PROJECT_NAME="OktaLogger"
SCHEME_NAME="OktaLoggerBuilder"

LOGGER_ROOT="${CI_DIRECTORY}"/..
pushd "${LOGGER_ROOT}"
pod install


