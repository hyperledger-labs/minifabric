#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script defines the main capabilities of this project

declare -A FUNCNAMES
declare -A OPNAMES
FUNCNAMES=([up]=networkUp [netup]=netUp [down]=networkDown \
  [restart]=networkRestart [generate]=generateCerts [cleanup]=cleanup)
OPNAMES=([install]='ccinstall' [approve]='ccapprove' [instantiate]='ccinstantiate' \
  [initialize]='ccinstantiate' [commit]='cccommit' [invoke]='ccinvoke' [create]='channelcreate' \
  [query]='ccquery' [join]='channeljoin' [blockquery]='blockquery' [channelquery]='channelquery' \
  [profilegen]='profilegen' [channelsign]='channelsign' [channelupdate]='channelupdate' \
  [anchorupdate]='anchorupdate' [dashup]='dashup' [dashdown]='dashdown' \
  [nodeimport]='nodeimport' [discover]='discover')

# Print the usage message
function printHelp() {
  echo "Usage: "
  echo "  minifab <mode> [options]"
  echo "    <mode> - one of operations or combination of operations separated by comma"
  echo ""
  echo "      - 'up' - bring up the network and do all default channel and chaincode operations"
  echo "      - 'netup' - bring up the network only"
  echo "      - 'down' - tear down the network"
  echo "      - 'restart' - restart the network"
  echo "      - 'generate' - generate required certificates and genesis block"
  echo "      - 'profilegen' - generate channel based profiles"
  echo "      - 'install'  - install chaincode"
  echo "      - 'approve'  - approve chaincode"
  echo "      - 'instantiate'  - instantiate chaincode for fabric release < 2.0"
  echo "      - 'initialize'  - initialize chaincode for fabric release >= 2.0"
  echo "      - 'commit'  - commit chaincode for fabric releases greater or equal to 2.0"
  echo "      - 'invoke'  - run chaincode invoke method"
  echo "      - 'query'  - run chaincode query method"
  echo "      - 'create'  - create application channel"
  echo "      - 'join'  - join all peers currently in the network to a channel"
  echo "      - 'blockquery'  - do channel block query and produce a channel tx json file"
  echo "      - 'channelquery'  - do channel query and produce a channel configuration json file"
  echo "      - 'channelsign'  - do channel config update signoff"
  echo "      - 'channelupdate'  - do channel update with a given new channel configuration json file" 
  echo "      - 'anchorupdate'  - do channel update which makes all peer nodes anchors for the all orgs"
  echo "      - 'nodeimport' - import external node certs and endpoints"
  echo "      - 'discover' - disocver channel endorsement policy"
  echo "      - 'cleanup'  - remove all the nodes and cleanup runtime files"
  echo ""
  echo "    options:"
  echo "    -c|--channel-name         - channel name to use (defaults to \"mychannel\")"
  echo "    -s|--database-type        - the database backend to use: goleveldb (default) or couchdb"
  echo "    -l|--chaincode-language   - the programming language of the chaincode being deployed: go (default), node, or java"
  echo "    -i|--fabric-release       - the fabric release to be used to launch the network (defaults to \"2.0\")"
  echo "    -n|--chaincode-name       - chaincode name to be installed/instantiated/approved"
  echo "    -b|--block-number         - block number to be queried"
  echo "    -v|--chaincode-version    - chaincode version to be installed"
  echo "    -p|--chaincode-parameters - chaincode instantiation and invocation parameters"
  echo "    -t|--transient-parameters - chaincode instantiation and invocation transient parameters"
  echo "    -r|--chaincode-private    - flag if chaincode processes private data, default is false"
  echo "    -e|--expose-endpoints     - make all the node endpoints available outside of the server"
  echo "    -o|--organization         - organization to be used for org specific operations"
  echo "    -y|--chaincode-policy     - chaincode policy"
  echo "    -d|--init-required        - chaincode initialization flag, default is true"
  echo "    -h|--help                 - print this message"
  echo
}

function doDefaults() {
  declare -a params=("CHANNEL_NAME" "CC_LANGUAGE" "IMAGETAG" "BLOCK_NUMBER" "CC_VERSION" \
    "CC_NAME" "DB_TYPE" "CC_PARAMETERS" "EXPOSE_ENDPOINTS" "CURRENT_ORG" "TRANSIENT_DATA" \
    "CC_PRIVATE" "CC_POLICY" "CC_INIT_REQUIRED")
  if [ ! -f "./vars/envsettings" ]; then
    cp envsettings vars/envsettings
  fi
  source ./vars/envsettings
  for value in ${params[@]}; do
    if [ -z ${!value+x} ]; then
      tt="$value=$"XX_"$value"
      eval "$tt"
    fi
  done
  echo "#!/bin/bash"> ./vars/envsettings
  for value in ${params[@]}; do
    echo 'declare XX_'$value="'"${!value}"'" >> ./vars/envsettings
  done
}

function netUp() {
  ansible-playbook -i hosts -e "mode=apply"                                           \
  -e "hostroot=$hostroot" -e "regcerts=false" -e "CC_LANGUAGE=$CC_LANGUAGE"           \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS" -e "EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"           \
  -e "ADDRS=$ADDRS" -e "TRANSIENT_DATA=$TRANSIENT_DATA" -e "CC_PRIVATE=$CC_PRIVATE"   \
  -e "CC_INIT_REQUIRED=$CC_INIT_REQUIRED" minifabric.yaml
  docker ps -a --format "{{.Names}}:{{.Ports}}"
}


function networkUp() {
  ansible-playbook -i hosts -e "mode=apply"                                           \
  -e "hostroot=$hostroot" -e "regcerts=false" -e "CC_LANGUAGE=$CC_LANGUAGE"           \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS" -e "EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"           \
  -e "ADDRS=$ADDRS" -e "TRANSIENT_DATA=$TRANSIENT_DATA" -e "CC_PRIVATE=$CC_PRIVATE"   \
  -e "CC_POLICY=$CC_POLICY" -e "CC_INIT_REQUIRED=$CC_INIT_REQUIRED" minifabric.yaml

  ansible-playbook -i hosts                                                           \
  -e "mode=channelcreate,channeljoin,anchorupdate,profilegen,ccinstall,ccapprove,cccommit,ccinstantiate,discover" \
  -e "hostroot=$hostroot" -e "CC_LANGUAGE=$CC_LANGUAGE"                               \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS" -e "EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"           \
  -e "ADDRS=$ADDRS" -e "TRANSIENT_DATA=$TRANSIENT_DATA" -e "CC_PRIVATE=$CC_PRIVATE"   \
  -e "CC_POLICY=$CC_POLICY" -e "CURRENT_ORG=$CURRENT_ORG"                             \
  -e "CC_INIT_REQUIRED=$CC_INIT_REQUIRED" fabops.yaml
  echo 'Running Nodes:'
  docker ps -a --format "{{.Names}}:{{.Ports}}"
}

function networkDown() {
  ansible-playbook -i hosts -e "mode=destroy"                                         \
  -e "hostroot=$hostroot"  -e "removecert=false" -e "CC_LANGUAGE=$CC_LANGUAGE"        \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS"  -e "EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"          \
  -e "ADDRS=$ADDRS" -e "TRANSIENT_DATA=$TRANSIENT_DATA" -e "CC_PRIVATE=$CC_PRIVATE"   \
  -e "CC_POLICY=$CC_POLICY" -e "CURRENT_ORG=$CURRENT_ORG"                             \
  -e "CC_INIT_REQUIRED=$CC_INIT_REQUIRED" minifabric.yaml
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
  -e "ADDRS=$ADDRS" -e "TRANSIENT_DATA=$TRANSIENT_DATA" -e "CC_PRIVATE=$CC_PRIVATE"   \
  -e "CC_POLICY=$CC_POLICY" -e "CC_INIT_REQUIRED=$CC_INIT_REQUIRED"                   \
  minifabric.yaml --skip-tags "nodes"
}

function doOp() {
  ansible-playbook -i hosts                                                           \
  -e "mode=$1" -e "hostroot=$hostroot" -e "CC_LANGUAGE=$CC_LANGUAGE"                  \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS"  -e "EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"          \
  -e "ADDRS=$ADDRS" -e "CURRENT_ORG=$CURRENT_ORG" -e "BLOCK_NUMBER=$BLOCK_NUMBER"     \
  -e "TRANSIENT_DATA=$TRANSIENT_DATA" -e "CC_PRIVATE=$CC_PRIVATE"                     \
  -e "CC_POLICY=$CC_POLICY" -e "CC_INIT_REQUIRED=$CC_INIT_REQUIRED" fabops.yaml
}

function cleanup {
  networkDown
  rm -rf vars/*
}

funcname=''
funcparams=''

function isValidateCMD() {
  if [ -z $MODE ] || [[ '-h' == "$MODE" ]] || [[ '--help' == "$MODE" ]]; then
    printHelp
    exit
  fi
  readarray -td, cmds < <(printf '%s' "$MODE")
  hasNet=0;hasOp=0
  for i in "${cmds[@]}"; do
    key=$(echo "${i,,}"|xargs)
    if [ ! -z "${FUNCNAMES[$key]}" ]; then
      hasNet=1
      funcname="${FUNCNAMES[$key]}"
    elif  [ ! -z "${OPNAMES[$key]}" ]; then
      hasOp=1
      funcname='doOp'
      if [ -z "$funcparams" ]; then
        funcparams="${OPNAMES[$key]}"
      else
        funcparams="$funcparams","${OPNAMES[$key]}"
      fi
    else
      echo "'"${i}"'"' is a not supported command!'
      exit 1
    fi
  done
  if [[ $(($hasNet+$hasOp)) == 0 ]]; then
    printHelp
    exit
  elif [[ $(($hasNet+$hasOp)) > 1 ]]; then
    echo 'Mixing network setting up and operation commands is not allowed!'
    exit 1
  fi
}

function startMinifab() {
  time $funcname $funcparams
}
