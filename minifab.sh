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

MODE=$1
shift
rs=$(isValidateOp $MODE)

# Determine whether starting, stopping, restarting, generating or upgrading
if [ "$rs" == 0 ]; then
  printHelp
  exit 1
fi

while getopts "h?c:s:l:i:n:v:p:e:o:" opt; do
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
  e)
    EXPOSE_ENDPOINTS=$OPTARG
    ;;
  o)
    DASH_ORG=$OPTARG
    ;;
  esac
done

doDefaults

echo "Current parameters used in the process:"
echo "CHANNEL_NAME=$CHANNEL_NAME"
echo "DB_TYPE=$DB_TYPE"
echo "IMAGETAG=$IMAGETAG"
echo "CC_LANGUAGE=$CC_LANGUAGE"
echo "CC_VERSION=$CC_VERSION"
echo "CC_NAME=$CC_NAME"
echo "CC_PARAMETERS=$CC_PARAMETERS"
echo "EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"
echo "ADDRS=$ADDRS"

CC_PARAMETERS=$(echo $CC_PARAMETERS|base64)

if [ -z "$hostroot" ]; then hostroot=$(pwd); fi
echo "hostroot: $hostroot"
if [ ! -d "$(pwd)/vars/chaincode" ]; then
  mkdir -p $(pwd)/vars/chaincode/simple $(pwd)/vars/chaincode/cmcc
  cp -r $(pwd)/chaincode/cmcc/* $(pwd)/vars/chaincode/cmcc
  if [[ "$IMAGETAG" = "2.0" ]] || [[ "$IMAGETAG" > "2.0" ]]; then
    cp -r $(pwd)/chaincode/simple2/* $(pwd)/vars/chaincode/simple
  else
    cp -r $(pwd)/chaincode/simple/* $(pwd)/vars/chaincode/simple
  fi
fi

if [ "${MODE}" == "up" ]; then
  time networkUp
elif [ "${MODE}" == "down" ]; then ## Clear the network
  time networkDown
elif [ "${MODE}" == "generate" ]; then ## Generate Artifacts
  time generateCerts
elif [ "${MODE}" == "restart" ]; then ## Restart the network
  time networkRestart
elif [ "${MODE}" == "install" ]; then ## Chaincode install
  time doOp ccinstall
elif [ "${MODE}" == "instantiate" ]; then ## Chaincode instantiate
  time doOp ccinstantiate
elif [ "${MODE}" == "invoke" ]; then ## Chaincode invoke
  time doOp ccinvoke
elif [ "${MODE}" == "create" ]; then ## Channel create
  time doOp channelcreate
elif [ "${MODE}" == "join" ]; then ## Channel join
  time doOp channeljoin
elif [ "${MODE}" == "dashup" ]; then ## Channel join
  time doOp dashup
elif [ "${MODE}" == "dashdown" ]; then ## Channel join
  time doOp dashdown
elif [ "${MODE}" == "cleanup" ]; then ## Channel join
  time cleanup
else
  printHelp
  exit 1
fi