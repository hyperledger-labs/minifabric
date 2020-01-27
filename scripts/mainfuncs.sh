#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script defines the main capabilities of this project

function isValidateOp() {
  ops="up down restart generate install instantiate invoke create join dashup dashdown cleanup"
  [[ $ops =~ (^|[[:space:]])$1($|[[:space:]]) ]] && echo 1 || echo 0
}

# Print the usage message
function printHelp() {
  echo "Usage: "
  echo "  minifab <mode> [-c <channel name>] [-s <dbtype>] [-l <language>] [-i <imagetag>] [-n <cc name>] [-v <cc version>] [-p <instantiate parameters>]"
  echo "    <mode> - one of operations"
  echo ""
  echo "       - 'up' - bring up the network"
  echo "       - 'down' - tear down the network"
  echo "       - 'restart' - restart the network"
  echo "       - 'generate' - generate required certificates and genesis block"
  echo "       - 'install'  - install chaincode"
  echo "       - 'instantiate'  - instantiate chaincode"
  echo "       - 'invoke'  - invoke a chaincode method"
  echo "       - 'create'  - create application channel"
  echo "       - 'join'  - join all peers currently in the network to a channel"
  echo "       - 'dashup'  - start up consortium management dashboard"
  echo "       - 'dashdown'  - shutdown consortium management dashboard"
  echo "       - 'cleanup'  - remove all the nodes and cleanup runtime files"
  echo ""
  echo "    -c <channel name> - channel name to use (defaults to \"mychannel\")"
  echo "    -s <dbtype> - the database backend to use: goleveldb (default) or couchdb"
  echo "    -l <language> - the programming language of the chaincode to deploy: go (default), node, or java"
  echo "    -i <imagetag> - the tag to be used to launch the network (defaults to \"1.4.4\")"
  echo "    -n <chaincode name> - chaincode name to be installed"
  echo "    -v <chaincode version> - chaincode version"
  echo "    -p <instantiate parameters> - chaincode instantiation parameters"
  echo "    -e <true|false> make all the node endpoints available outside of the minifab network"
  echo "    -o <orgname> organization name to be used for start up or shutdown consortium management dashboard"
  echo "  minifab -h (print this message)"
  echo
  echo "Use all defaults to stand up a fabric network:"
  echo
  echo "    minifab up"
  echo "    minifab down"
  echo
  echo "The first command will stand up fabric network, create default channel, join the"
  echo "channel, install and instantiate sample chaincode. The second command will destroy"
  echo "everything"
  echo
  echo "Here are few examples to do other things:"
  echo
  echo "    minifab generate -c mychannel"
  echo "    minifab up -c mychannel"
  echo "    minifab up -i 2.0"
  echo "    minifab create -c anotherchannel"
  echo "    minifab join -c anotherchannel"
  echo "    minifab install -n anothercc"
  echo "    minifab instantiate -n anothercc -v 2.0"
  echo
}

function doDefaults() {
  declare -a params=("CHANNEL_NAME" "CC_LANGUAGE" "IMAGETAG" "CC_VERSION" "CC_NAME" "DB_TYPE" "CC_PARAMETERS" "EXPOSE_ENDPOINTS" "DASH_ORG")
  if [ ! -f "./vars/envsettings" ]; then
    cp envsettings vars/envsettings
  fi
  source ./vars/envsettings
  for value in ${params[@]}; do
    eval "tt=${!value}"
    if [ -z ${tt} ]; then
      tt="$value=$"XX_"$value"
      eval "$tt"
    fi
  done
  echo "#!/bin/bash"> ./vars/envsettings
  for value in ${params[@]}; do
    tt="${!value}"
    echo 'declare XX_'$value="'"$tt"'" >> ./vars/envsettings
  done
}

function networkUp() {
  ansible-playbook -i hosts -e "mode=apply"                                           \
  -e "hostroot=$hostroot" -e "regcerts=false" -e "CC_LANGUAGE=$CC_LANGUAGE"           \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS" -e "EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"           \
  -e "ADDRS=$ADDRS" minifabric.yaml
# Only do the following operations when there is at least one orderer node exists  
  if [ -f "./vars/orderendpoints.yaml" ]; then
  ansible-playbook -i hosts                                                           \
  -e "mode=channelcreate,channeljoin,ccinstall,ccinstantiate,channelupdate"           \
  -e "hostroot=$hostroot" -e "CC_LANGUAGE=$CC_LANGUAGE"                               \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS" -e "EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"           \
  -e "ADDRS=$ADDRS" fabops.yaml
  echo 'Running Nodes:'
  docker ps -a --format "{{.Names}}:{{.Ports}}"
  fi
}

function networkDown() {
  ansible-playbook -i hosts -e "mode=destroy"                                         \
  -e "hostroot=$hostroot"  -e "removecert=false" -e "CC_LANGUAGE=$CC_LANGUAGE"        \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS"  -e "EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"          \
  -e "ADDRS=$ADDRS" minifabric.yaml
}

function networkRestart() {
  networkDown
  networkUp
}

function generateCerts() {
  ansible-playbook -i hosts -e "mode=apply"                                           \
  -e "hostroot=$hostroot"  -e "regcerts=true" -e "CC_LANGUAGE=$CC_LANGUAGE"           \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS"  -e "EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"          \
  -e "ADDRS=$ADDRS" minifabric.yaml --skip-tags "nodes"
}

function doOp() {
  ansible-playbook -i hosts                                                           \
  -e "mode=$1" -e "hostroot=$hostroot" -e "CC_LANGUAGE=$CC_LANGUAGE"                  \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS"  -e "EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"          \
  -e "ADDRS=$ADDRS" -e "DASH_ORG=$DASH_ORG" fabops.yaml
}

function cleanup {
  networkDown
  rm -rf vars/*
}
