#!/bin/bash

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

# Run Lint Test
bundle exec fastlane lint action:"$action"
