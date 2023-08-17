#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script defines the main capabilities of this project
r
declare -A OPNAMES
LINE0='imageget,netup'
OPNAMES=([up]="$LINE0" [init]='imageget,init' [start]='start' \
  [restart]='stop,start' \
  [clean]='stop,filerem' \
  [stop]='stop' )

# Print the usage message
function printHelp() {
  echo "Usage: "
  echo "  minindy <mode> [options]"
  echo "    <mode> - one of operations or combination of operations separated by comma"
  echo ""
  echo "      - 'up' - bring up the network and do all default parameters"
  echo "      - 'init' - init the validator nodes info"
  echo "      - 'start' - bring up the network"
  echo "      - 'stop' - tear down the network"
  echo "      - 'restart' - restart the network"
  echo "      - 'clean'  - remove all the nodes and cleanup runtime files"
  echo ""
  echo "    options:"
  echo "    -a|--target-environment   - set desired network environment, options are: DOCKER, K8SCLASSIC, K8SOPERATOR"
  echo "    -o|--steward              - steward to be used for org specific operations"
  echo "    -h|--help                 - print this message"
  echo
}

function doDefaults() {
  declare -a params=("CURRENT_STWD" "TARGET_ENV")
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
  ansible-playbook -i hosts -e "mode=$1" -e "hostroot=$hostroot" -e "ADDRS=$ADDRS" \
  -e "CURRENT_ORG=$CURRENT_ORG" -e "TARGET_ENVIRONMENT=$TARGET_ENV" ops.yaml
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
  varpath=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/home/vars" }}{{ .Source }}{{ end }}{{ end }}' minindy)
  hostroot=${varpath%/vars}
  hostroot=${hostroot//\\/\/}
}

function startMinIndy() {
  export ANSIBLE_STDOUT_CALLBACK=$RUN_OUTPUT
  time doOp $funcparams
}
