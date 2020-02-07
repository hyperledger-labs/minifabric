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
isValidateOp

while getopts "h?c:b:s:l:i:n:v:p:e:o:g:t:u:" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  b)
    BLOCK_NUMBER=$OPTARG
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
  t)
    TRANSIENT_DATA=$OPTARG
    ;;
  u)
    CC_PRIVATE=$OPTARG
    ;;
  esac
done

doDefaults

echo "Minifab Execution Context:"
echo "    FABRIC_RELEASE=$IMAGETAG"
echo "    CHANNEL_NAME=$CHANNEL_NAME"
echo "    PEER_DB_TYPE=$DB_TYPE"
echo "    CC_LANGUAGE=$CC_LANGUAGE"
echo "    CC_NAME=$CC_NAME"
echo "    CC_VERSION=$CC_VERSION"
echo "    CC_PARAMETERS=$CC_PARAMETERS"
echo "    CC_PRIVATE=$CC_PRIVATE"
echo "    TRANSIENT_DATA=$TRANSIENT_DATA"
echo "    BLOCK_NUMBER=$BLOCK_NUMBER"
echo "    EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"
echo "    HOST_ADDRESSES=$ADDRS"

CC_PARAMETERS=$(echo $CC_PARAMETERS|base64)
TRANSIENT_DATA=$(echo $TRANSIENT_DATA|base64)

if [ -z "$hostroot" ]; then hostroot=$(pwd); fi
echo "    WORKING_DIRECTORY: $hostroot"
if [ ! -d "$(pwd)/vars/chaincode" ]; then
  cp -r $(pwd)/chaincode $(pwd)/vars/
fi

startMinifab