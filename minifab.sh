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

. scripts/mainfuncs.sh

# channel name defaults to "firstchannel"
CHANNEL_NAME="firstchannel"
# use go as the default language for chaincode
CC_LANGUAGE=go
# default image tag
IMAGETAG="1.4.4"
# default chaincode version
CC_VERSION=1.0
# default chaincode name
CC_NAME="chaincode_example02"
# default peer db set to golevel
DB_TYPE=golevel
# default instantiate parameters
CC_PARAMETERS='"init","a","100","b","200"'

MODE=$1
shift
rs=$(isValidateOp $MODE)

# Determine whether starting, stopping, restarting, generating or upgrading
if [ "$rs" == 0 ]; then
  printHelp
  exit 1
fi

while getopts "h?c:s:l:i:n:v:p" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  c)
    CHANNEL_NAME=$OPTARG
    ;;
  s)
    DB_TYPE=$OPTARG
    ;;
  l)
    CC_LANGUAGE=$OPTARG
    ;;
  i)
    IMAGETAG=$OPTARG
    ;;
  n)
    CC_NAME=$OPTARG
    ;;
  v)
    CC_VERSION=$OPTARG
    ;;
  p)
    CC_PARAMETERS=$OPTARG
    ;;
  esac
done

CC_PARAMETERS=$(echo $CC_PARAMETERS|base64)
echo "Current settings"
echo "DB_TYPE: ${DB_TYPE}"
echo "CHANNEL_NAME: ${CHANNEL_NAME}"
echo "CC_NAME: ${CC_NAME}"
echo "CC_VERSION: ${CC_VERSION}"
echo "CC_LANGUAGE: ${CC_LANGUAGE}"
echo "CHANNEL_NAME: ${CHANNEL_NAME}"
echo "IMAGETAG: ${IMAGETAG}"
echo "CC_PARAMETERS: ${CC_PARAMETERS}"

if [ -z "$hostroot" ]; then hostroot=$(pwd); fi
echo "hostroot: $hostroot"
[ ! -d "$(pwd)/vars/chaincode" ] && cp -r $(pwd)/chaincode $(pwd)/vars

if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "down" ]; then ## Clear the network
  networkDown
elif [ "${MODE}" == "generate" ]; then ## Generate Artifacts
  generateCerts
elif [ "${MODE}" == "restart" ]; then ## Restart the network
  networkDown
  networkUp
elif [ "${MODE}" == "install" ]; then ## Chaincode install
  doOp ccinstall
elif [ "${MODE}" == "instantiate" ]; then ## Chaincode instantiate
  doOp ccinstantiate
elif [ "${MODE}" == "create" ]; then ## Channel create
  doOp channelcreate
elif [ "${MODE}" == "join" ]; then ## Channel join
  doOp channeljoin
else
  printHelp
  exit 1
fi