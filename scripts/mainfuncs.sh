#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script defines the main capabilities of this project

# Print the usage message
function printHelp() {
  echo "Usage: "
  echo "  minifab.sh <mode> [-c <channel name>] [-t <timeout>] [-d <delay>] [-f <docker-compose-file>] [-s <dbtype>] [-l <language>] [-o <consensus-type>] [-i <imagetag>] [-a] [-n] [-v]"
  echo "    <mode> - one of 'up', 'down', 'restart', 'generate' or 'upgrade'"
  echo "      - 'up' - bring up the network with docker-compose up"
  echo "      - 'down' - clear the network with docker-compose down"
  echo "      - 'restart' - restart the network"
  echo "      - 'generate' - generate required certificates and genesis block"
  echo "      - 'upgrade'  - upgrade the network from version 1.3.x to 1.4.0"
  echo "    -c <channel name> - channel name to use (defaults to \"mychannel\")"
  echo "    -t <timeout> - CLI timeout duration in seconds (defaults to 10)"
  echo "    -d <delay> - delay duration in seconds (defaults to 3)"
  echo "    -s <dbtype> - the database backend to use: goleveldb (default) or couchdb"
  echo "    -l <language> - the programming language of the chaincode to deploy: go (default), javascript, or java"
  echo "    -i <imagetag> - the tag to be used to launch the network (defaults to \"latest\")"
  echo "    -a - launch certificate authorities (no certificate authorities are launched by default)"
  echo "    -n - do not deploy chaincode (abstore chaincode is deployed by default)"
  echo "    -v - verbose mode"
  echo "  minifab.sh -h (print this message)"
  echo
  echo "Typically, one would first generate the required certificates and "
  echo "genesis block, then bring up the network. e.g.:"
  echo
  echo "	minifab.sh generate -c mychannel"
  echo "	minifab.sh up -c mychannel -s couchdb"
  echo "        minifab.sh up -c mychannel -s couchdb -i 1.4.0"
  echo "	minifab.sh up -l javascript"
  echo "	minifab.sh down -c mychannel"
  echo "        minifab.sh upgrade -c mychannel"
  echo
  echo "Taking all defaults:"
  echo "	minifab.sh generate"
  echo "	minifab.sh up"
  echo "	minifab.sh down"
}

function networkUp() {
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/home/plays \
  hfrd/ansible:latest ansible-playbook -i plays/hosts -e "mode=apply hostroot=$(pwd)" plays/minifabric.yaml
}

function networkDown() {
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/home/plays \
  hfrd/ansible:latest ansible-playbook -i plays/hosts -e "mode=destroy removecert=true" plays/minifabric.yaml
}

function generateCerts() {
  docker run --rm -v $(pwd):/home/plays hfrd/ansible:latest \
    ansible-playbook -i plays/hosts -e "mode=apply" plays/minifabric.yaml \
    --skip-tags "nodes"
}