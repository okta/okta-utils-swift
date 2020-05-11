#!/usr/bin/env bash -lx

LOGGER_ROOT="${CI_DIRECTORY}"/..
pushd "${LOGGER_ROOT}"
pod install


