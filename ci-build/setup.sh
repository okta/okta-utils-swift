#!/usr/bin/env bash -lx

PROJECT_NAME="OktaLogger"

LOGGER_ROOT="${CI_DIRECTORY}"/..
pushd "${LOGGER_ROOT}"
pod install


