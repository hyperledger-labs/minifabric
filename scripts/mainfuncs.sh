#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script defines the main capabilities of this project

function isValidateOp() {
  ops="up down restart generate install instantiate create join"
  [[ $ops =~ (^|[[:space:]])$1($|[[:space:]]) ]] && echo 1 || echo 0
}

# Print the usage message
function printHelp() {
  echo "Usage: "
  echo "  minifab.sh <mode> [-c <channel name>] [-s <dbtype>] [-l <language>] [-i <imagetag>] [-n <cc name>] [-v <cc version>] [-p <instantiate parameters>]"
  echo "    <mode> - one of 'up', 'down', 'restart', 'generate', 'install', 'instantiate', 'create' or 'join'"
  echo "      - 'up' - bring up the network with docker-compose up"
  echo "      - 'down' - clear the network with docker-compose down"
  echo "      - 'restart' - restart the network"
  echo "      - 'generate' - generate required certificates and genesis block"
  echo "      - 'install'  - install chaincode"
  echo "      - 'instantiate'  - instantiate chaincode"
  echo "      - 'create'  - create application channel"
  echo "      - 'join'  - join all peers currently in the network to a channel"
  echo "    -c <channel name> - channel name to use (defaults to \"mychannel\")"
  echo "    -s <dbtype> - the database backend to use: goleveldb (default) or couchdb"
  echo "    -l <language> - the programming language of the chaincode to deploy: go (default), node, or java"
  echo "    -i <imagetag> - the tag to be used to launch the network (defaults to \"1.4.4\")"
  echo "    -n <chaincode name> - chaincode name to be installed"
  echo "    -v <chaincode version> - chaincode version"
  echo "    -p <instantiate parameters> - chaincode instantiation parameters"
  echo "  minifab.sh -h (print this message)"
  echo
  echo "Typically, one would first generate the required certificates and "
  echo "genesis block, then bring up the network. e.g.:"
  echo
  echo "	minifab.sh generate -c mychannel"
  echo "	minifab.sh up -c mychannel"
  echo "  minifab.sh up -s couchdb -i 1.4.0"
  echo "	minifab.sh down"
  echo
  echo "Taking all defaults:"
  echo "	minifab.sh generate"
  echo "	minifab.sh up"
  echo "	minifab.sh down"
}

function networkUp() {
  ansible-playbook -i hosts -e "mode=apply"                                           \
  -e "hostroot=$hostroot" -e "regcerts=false" -e "CC_LANGUAGE=$CC_LANGUAGE"              \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS" minifabric.yaml
}

function networkDown() {
  ansible-playbook -i hosts                                                           \
  -e "mode=destroy" -e "removecert=false" -e "CC_LANGUAGE=$CC_LANGUAGE"               \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS" minifabric.yaml
}

function generateCerts() {
  ansible-playbook                                                                    \
  -i hosts -e "mode=apply" -e "regcerts=true" -e "CC_LANGUAGE=$CC_LANGUAGE"           \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS" minifabric.yaml --skip-tags "nodes"
}

function doOp() {
  ansible-playbook -i hosts                                                           \
  -e "mode=$1" -e "hostroot=$hostroot" -e "CC_LANGUAGE=$CC_LANGUAGE"                     \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS" fabops.yaml
}
