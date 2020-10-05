# Join new org to the channel and install chaincode already running on other existing organizations

This document describe the fully process how to do the following:

add a new organization into existing fabric network
and also installOnce you have a new organization as part of the existing Fabric network by following the process
described in [Add New Organization](docs/AddNewOrganization.md), most likely you will need to join
the peers of the new organization to some channels and make sure that the peers will be running
the chaincode that already running on other org's peers so that the new peers can participate in
transactions.

This doc will describe the steps you need to take to make it happen. Assume that you have two
working directories, `mysite0` and `mysite1`. Each working directory will represent a site which
may include one or multiple orgs and peers. Here are example of the two spec.yaml files

```
cat mysite0/spec.yaml

fabric:
  peers:
  - "peer1.org0.example.com"
  - "peer2.org0.example.com"
  - "peer1.org1.example.com"
  - "peer2.org1.example.com"
  orderers:
  - "orderer1.example.com"
  - "orderer2.example.com"
  - "orderer3.example.com"

cat mysite1/spec.yaml

fabric:
  peers:
  - "peer1.orgx.example.com"
  - "peer2.orgx.example.com"

```
 
## Bring up both sites using the following commands

```
cd ~/mysite0
minifab up -e 7000 -n samplecc -p ''

cd ~/mysite1
minifab netup -e 7200 -o orgx.example.com
```

## Join orgx.example.com to the application channel with the following step
Since the mysite1 has the organization orgx.example.com, then the file produced
by Minifabric for joining an existing network will be called JoinRequest_orgx-example-com.json
if you name your organization differently, then that join request file will have
different file name, change these commands accordingly. This step basically is the duplicate
of the [Add New Organization](docs/AddNewOrganization.md) process with changes to match
the organizations used in this doc.

```
cd ~/mysite0
minifab channelquery
sudo cp ~/mysite1/vars/JoinRequest_orgx-example-com.json ~/mysite0/vars
```

Now make changes to the channel configuration file by using jq tool, notice that the command needs to be on one line

```
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {(.[1].values.MSP.value.config.name): .[1]}}}}}'
  vars/mychannel_config.json vars/JoinRequest_orgx-example-com.json |
  jq -s '.[0] * {"channel_group":{"groups":{"Application":{"version":
  (.[0].channel_group.groups.Application.version|tonumber + 1)|tostring }}}}' | sudo tee vars/mychannel_config.json
  > /dev/null
```

Inspect file `vars/mychannel_config.json` and make sure that everything is correct.

```
cd ~/mysite0
minifab channelsign,channelupdate
```

## Import orderer nodes to orgx.example.com and join peers of orgx.example.com to the `mychannel`
For orgx.example.com peers to participate in Fabric network, the organization must know where orderers nodes are.
To do that, we do `nodeimport`

```
cd ~/mysite1
sudo cp ~/mysite0/vars/profiles/endpoints.yaml vars
minifab nodeimport,join
```

## Install chaincode `samplecc` onto orgx peers

```
cd ~/mysite1
minifab install,approve -n samplecc -p ''
```

## Approve the chaincode on org0 and org1
Since new orgs joined, the chaincode will need to be approved again so that new org can also commit

```
cd ~/mysite0
minifab approve,commit
```


## Discover and verify the chaincode on orgx

```
cd ~/mysite1
minifab discover
```

Verify that the file `./vars/discover/mychannel/samplecc_endorsers.json` contains the orgx as
endorsing group.

```
cd ~/mysite1
minifab stats
```

The above command should show that mysite1 should have chaincode container like the following
running

```
  dev-peer1.orgx.example.com-samplecc_1.0-9ea5e3809f : Up 4 minutes
  dev-peer2.orgx.example.com-samplecc_1.0-9ea5e3809f : Up 4 minutes
```

## To use your own chaincode
If you want to use your own chaincode, then you should have the chaincode in vars/chaincode directory
and follow the structure to form chaincode. Then use your own chaincode in various commands.
