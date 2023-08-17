#!/bin/bash

export PATH=${PWD}/../bin:${PWD}:$PATH
export INDY_CFG_PATH=${PWD}
export VERBOSE=false
export DOCKER_API_VERSION=1.39

. scripts/mainfuncs.sh

MODE=$1
shift

while [[ $# -gt 0 ]]; do
optkey="$1"

case $optkey in
  -h|--help)
    printHelp; exit 0;;
  -s|--steward)
    CURRENT_STWD="$2";shift;shift;;
  -a|--target-environment)
    TARGET_ENV="$2";shift;shift;;
  *) # unknown option
    echo "$1 is a not supported option"; exit 1;;
esac
done

isValidateCMD

doDefaults

echo "MinIndy Execution Context:"
echo "    EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"
echo "    CURRENT_STWD=$CURRENT_STWD"
echo "    HOST_ADDRESSES=$ADDRS"
echo "    TARGET_ENV=$TARGET_ENV"

getRealRootDir

startMinIndy
