#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script defines the main capabilities of this project

declare -A OPNAMES
LINE0='imageget,certgen,netup,netstats,channelcreate,channeljoin,anchorupdate,'
LINE1='profilegen,ccinstall,ccapprove,cccommit,ccinstantiate,discover'
OPNAMES=([up]="$LINE0$LINE1" [netup]='imageget,certgen,netup,netstats' \
  [restart]='netdown,netup' [generate]='certrem,certgen' [configmerge]='configmerge' \
  [orgjoin]='channelquery,configmerge,channelsign,channelupdate' \
  [cleanup]='netdown,filerem' [stats]='netstats' [apprun]='apprun' \
  [down]='netdown' [install]='ccinstall' [approve]='ccapprove' \
  [instantiate]='ccinstantiate' [initialize]='ccinstantiate' \
  [commit]='cccommit' [invoke]='ccinvoke' [create]='channelcreate' \
  [query]='ccquery' [join]='channeljoin' [blockquery]='blockquery' \
  [channelquery]='channelquery' [profilegen]='profilegen' [caliperrun]='caliperrun' \
  [channelsign]='channelsign' [channelupdate]='channelupdate' \
  [portainerup]='portainerup' [portainerdown]='portainerdown' \
  [anchorupdate]='anchorupdate' [explorerup]='explorerup' [explorerdown]='explorerdown' \
  [consoleup]='consoleup' [consoledown]='consoledown' \
  [ccup]='ccinstall,ccapprove,cccommit,ccinstantiate,discover,channelquery' \
  [nodeimport]='nodeimport' [discover]='discover' [imageget]='imageget' [update]='update' \
  [deployoperator]='deployoperator' [deploynodes]='deploynodes')

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
  echo "      - 'discover' - discover channel endorsement policy"
  echo "      - 'cleanup'  - remove all the nodes and cleanup runtime files"
  echo "      - 'stats'  - list all nodes and status"
  echo "      - 'explorerup'  - start up Hyperledger explorer"
  echo "      - 'explorerdown'  - shutdown Hyperledger explorer"
  echo "      - 'portainerup'  - start up portainer web management"
  echo "      - 'portainerdown'  - shutdown portainer web management"
  echo "      - 'ccup'  - update or force re-install chaincode as specified version (alias to install,approve,commit,instantiate/initialize)."
  echo "      - 'deployoperator'  - deploy fabric-operator to k8s environment"
  echo "      - 'deploynodes'  - deploy nodes from vars/nodespecs"
  echo "      - 'apprun'  - (experimental) run chaincode app if there is any"
  echo "      - 'caliperrun'  - (experimental) run caliper test"
  echo "      - 'orgjoin'  - (experimental) join an org to the current channel"
  echo "      - 'update'  - (experimental) update minifabric to the latest version"
  echo ""
  echo "    options:"
  echo "    -a|--target-environment   - set desired network environment, options are: DOCKER, K8SCLASSIC, K8SOPERATOR"
  echo "    -c|--channel-name         - channel name to use (defaults to \"mychannel\")"
  echo "    -s|--database-type        - the database backend to use: goleveldb (default) or couchdb"
  echo "    -l|--chaincode-language   - the language of the chaincode: go (default), node, or java"
  echo "    -i|--fabric-release       - the fabric release to be used to launch the network (defaults to \"2.1\")"
  echo "    -n|--chaincode-name       - chaincode name to be installed/instantiated/approved"
  echo "    -b|--block-number         - block number to be queried"
  echo "    -v|--chaincode-version    - chaincode version to be installed"
  echo "    -p|--chaincode-parameters - chaincode instantiation and invocation parameters"
  echo "    -t|--transient-parameters - chaincode instantiation and invocation transient parameters"
  echo "    -r|--chaincode-private    - flag if chaincode processes private data, default is false"
  echo "    -e|--expose-endpoints     - flag if node endpoints should be exposed, default is false"
  echo "    -o|--organization         - organization to be used for org specific operations"
  echo "    -y|--chaincode-policy     - chaincode policy"
  echo "    -d|--init-required        - chaincode initialization flag, default is true"
  echo "    -f|--run-output           - minifabric run time output callback, can be 'minifab'(default), 'default', 'dense'"
  echo "    -h|--help                 - print this message"
  echo
}

function doDefaults() {
  declare -a params=("CHANNEL_NAME" "CC_LANGUAGE" "IMAGETAG" "BLOCK_NUMBER" "CC_VERSION" \
    "CC_NAME" "DB_TYPE" "CC_PARAMETERS" "EXPOSE_ENDPOINTS" "CURRENT_ORG" "TRANSIENT_DATA" \
    "CC_PRIVATE" "CC_POLICY" "CC_INIT_REQUIRED" "RUN_OUTPUT" "TARGET_ENV")
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

function doOp() {
  ansible-playbook -i hosts                                                           \
  -e "mode=$1" -e "hostroot=$hostroot" -e "CC_LANGUAGE=$CC_LANGUAGE"                  \
  -e "DB_TYPE=$DB_TYPE" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "CC_NAME=$CC_NAME"         \
  -e "CC_VERSION=$CC_VERSION" -e "CHANNEL_NAME=$CHANNEL_NAME" -e "IMAGETAG=$IMAGETAG" \
  -e "CC_PARAMETERS=$CC_PARAMETERS"  -e "EXPOSE_ENDPOINTS=$EXPOSE_ENDPOINTS"          \
  -e "ADDRS=$ADDRS" -e "CURRENT_ORG=$CURRENT_ORG" -e "BLOCK_NUMBER=$BLOCK_NUMBER"     \
  -e "TRANSIENT_DATA=$TRANSIENT_DATA" -e "CC_PRIVATE=$CC_PRIVATE"                     \
  -e "CC_POLICY=$CC_POLICY" -e "CC_INIT_REQUIRED=$CC_INIT_REQUIRED"                   \
  -e "TARGET_ENVIRONMENT=$TARGET_ENV" fabops.yaml
}

funcparams='optionverify'

function isValidateCMD() {
  if [ -z $MODE ] || [[ '-h' == "$MODE" ]] || [[ '--help' == "$MODE" ]]; then
    printHelp
    exit
  fi
  readarray -td, cmds < <(printf '%s' "$MODE")
  for i in "${cmds[@]}"; do
    key=$(echo "${i,,}"|xargs)
    if  [ ! -z "${OPNAMES[$key]}" ]; then
      funcparams="$funcparams","${OPNAMES[$key]}"
    else
      echo "'"${i}"'"' is a not supported command!'
      exit 1
    fi
  done
  if [[ $funcparams == 'optionverify' ]]; then
    printHelp
    exit
  fi
}

function getRealRootDir() {
  varpath=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/home/vars" }}{{ .Source }}{{ end }}{{ end }}' minifab)
  hostroot=${varpath%/vars}
  hostroot=${hostroot//\\/\/}
}

function startMinifab() {
  export ANSIBLE_STDOUT_CALLBACK=$RUN_OUTPUT
  time doOp $funcparams
}
