# Expand an existing Fabric network with a new org

This document describes the process how to do the following:

0. Set up two sites, one is considered an existing Fabric network, the other one is considered a new organization
1. Add a new organization into existing fabric network
2. Join peers from the new organization to the existing channel
3. Install chaincode running on the existing peers onto new peers
4. Approve and commit the chaincode
5. Verify endorsement and chaincode containers

Assume that you have two working directories, `mysite0` and `mysite1` under your root directory. Each working
directory will represent a site which may include one or multiple orgs and peers, the two working directory
can very well be on differnt servers, in that case, you will need to have other means such as `scp` to transfer
necessary files between servers. Here are the two spec.yaml files

```
cat ~/mysite0/spec.yaml

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

cat ~/mysite1/spec.yaml

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

The first command brings up a complete running fabric network with a channel named `mychannel`
created and chaincode named `samplecc` installed, approved, committed and initialized. There are
two peer orgs and one orderer org. Once the command finished successfully, it is a fully running
Fabric network and consider this as an existing Fabric network.

The second command brings up a new organization with only two peer nodes. No channel, no orderer
nodes, just two peer nodes up running.

## Join orgx.example.com to the application channel with the following step
Since the mysite1 has the organization orgx.example.com, then the file produced
by Minifabric for joining an existing network will be called `JoinRequest_orgx-example-com.json`
under `~/mysite1/vars` directory. If you have different name for your organization, then the
join request file will have different file name, make changes accordingly when you run the commands. 

```
cd ~/mysite0
sudo cp ~/mysite1/vars/JoinRequest_orgx-example-com.json ~/mysite0/vars/NewOrgJoinRequest.json
minifab orgjoin
```

## Import orderer nodes to orgx.example.com and join peers of orgx.example.com to the `mychannel`
For orgx.example.com peers to participate in Fabric network, the organization must know where orderers nodes are.
To do that, we do `nodeimport`

```
cd ~/mysite1
sudo cp ~/mysite0/vars/profiles/endpoints.yaml vars
minifab nodeimport,join
```

## Install and approve chaincode `samplecc` for orgx peers

```
cd ~/mysite1
minifab install,approve -n samplecc -p ''
```

## Approve the chaincode on org0 and org1
Since new orgs joined, the chaincode will need to be approved again so that new org can also commit

```
cd ~/mysite0
minifab approve,discover,commit
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
