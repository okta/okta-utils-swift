#!/bin/bash
set -x
usage()
{
  echo "
  Usage: $0 [-l|-a].
  
  Display Linting Errors (Default option)

	$0 -l

  Autocorrect linting errors
  	
	$0 -a 

  Usage	
  	$0 -h
	
  "
  exit 2
}

while getopts ":ha" opt; do
  case ${opt} in
    a ) # process option h
      	action="autocorrect"	
      	;;
    l )
	action="lint"
      	;;
    h|? ) 
    	usage
    	;;
  esac
done

#echo "------------"
#echo "DART ENVIRONMENT"
#echo "-------------"
#env
#
#echo "-----------------------------"

CI_DIRECTORY=$(cd `dirname $0` && pwd)
source "${CI_DIRECTORY}/setup.sh"
pushd "${LOGGER_ROOT}"

# Main
pushd "${LOGGER_ROOT}"
printBuildEnvironment

# Run Lint Test
runSwiftLint
