#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script will orchestrate a simple execution of the Hyperledger
# Fabric network.
#
# The end-to-end verification provisions a sample Fabric network consisting of
# two organizations, each maintaining two peers, and a Raft ordering service.

# prepending $PWD/../bin to PATH to ensure we are picking up the correct binaries
# this may be commented out to resolve installed version of tools if desired
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
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
  -b|--block-number)
    BLOCK_NUMBER="$2";shift;shift;;
  -c|--channel-name)
    CHANNEL_NAME="$2";shift;shift;;
  -s|--database-type)
    DB_TYPE="$2";shift;shift;;
  -l|--chaincode-language)
    CC_LANGUAGE="$2";shift;shift;;
  -i|--fabric-release)
    IMAGETAG="$2";shift;shift;;
  -n|--chaincode-name)
    CC_NAME="$2";shift;shift;;
  -v|--chaincode-version)
    CC_VERSION="$2";shift;shift;;
  -p|--chaincode-parameters)
    CC_PARAMETERS="$2";shift;shift;;
  -e|--expose-endpoints)
    EXPOSE_ENDPOINTS="$2";shift;shift;;
  -o|--organization)
    CURRENT_ORG="$2";shift;shift;;
  -t|--transient-parameters)
    TRANSIENT_DATA="$2";shift;shift;;
  -r|--chaincode-private)
    CC_PRIVATE="$2";shift;shift;;
  -y|--chaincode-policy)
    CC_POLICY="$2";shift;shift;;
  -d|--init-required)
    CC_INIT_REQUIRED="$2";shift;shift;;
  -f|--run-output)
    RUN_OUTPUT="$2";shift;shift;;
  *) # unknown option
    echo "$1 is a not supported option"; exit 1;;
esac
done

isValidateCMD
if [ ! -z ${CC_PARAMETERS+x} ]; then CC_PARAMETERS=$(echo "${CC_PARAMETERS}"|base64 | tr -d \\n); fi
if [ ! -z ${CC_POLICY+x} ]; then CC_POLICY=$(echo "${CC_POLICY}"|base64 | tr -d \\n); fi
if [ ! -z ${TRANSIENT_DATA+x} ]; then TRANSIENT_DATA=$(echo "${TRANSIENT_DATA}"|base64 | tr -d \\n); fi
doDefaults

echo "Minifab Execution Context:"
echo "    FABRIC_RELEASE=$IMAGETAG"
echo "    CHANNEL_NAME=$CHANNEL_NAME"
echo "    PEER_DATABASE_TYPE=$DB_TYPE"
echo "    CHAINCODE_LANGUAGE=$CC_LANGUAGE"
echo "    CHAINCODE_NAME=$CC_NAME"
echo "    CHAINCODE_VERSION=$CC_VERSION"
echo "    CHAINCODE_INIT_REQUIRED=$CC_INIT_REQUIRED"
echo "    CHAINCODE_PARAMETERS=$(echo $CC_PARAMETERS|base64 -d)"
echo "    CHAINCODE_PRIVATE=$CC_PRIVATE"
echo "    CHAINCODE_POLICY=$(echo $CC_POLICY|base64 -d)"
echo "    TRANSIENT_DATA=$(echo $TRANSIENT_DATA|base64 -d)"
echo "    BLOCK_NUMBER=$BLOCK_NUMBER"
echo "    EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"
echo "    CURRENT_ORG=$CURRENT_ORG"
echo "    HOST_ADDRESSES=$ADDRS"

getRealRootDir
echo "    WORKING_DIRECTORY: $hostroot"
if [ ! -d "$(pwd)/vars/chaincode" ]; then
  cp -r $(pwd)/chaincode $(pwd)/vars/
fi
if [ ! -d "$(pwd)/vars/app" ]; then
  cp -r $(pwd)/app $(pwd)/vars/
fi

startMinifab
