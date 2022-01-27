# Running Minifabric on ARM

This document lists the known issues that you may experience trying to operate minifabric on ARM hardware. 
Related issue(s): [#293](https://github.com/hyperledger-labs/minifabric/issues/293)

## General Approach

Minifabric acts as a deployment tool, using given docker images of Hyperledger Fabric. Therefore, we manipulated all references to docker images inside the source code of minifabric and built it locally (see [build minifabric locally](https://github.com/hyperledger-labs/minifabric/blob/main/docs/README.md#build-minifabric-locally)). You can search and replace the entries in the source code files for the cloned minifabric repo by static references to ARM images of Fabric. In general, this approach requires building dedicated docker images for ARM and following we list further considerations.

For a quick start with Fabric version 2.1, please refer to the following samples (be careful, no warranty):
- fabric sources and docs to build ARM64 images https://github.com/chinyati/Hyperledger-Fabric-ARM64-images.
- minifabric sample of where to set the relevant static references, see the commit [static-arm64-references](https://github.com/LIONS-DLT/minifabric/commit/810fc1177c9d4cf4ef1adf678ee3cf42f1325ea8)

## Fabric Images for ARM64

Running ARM64 docker images compatible with minifabric, make sure your images are fulfilling the following requirements.

### CLI Container

Make sure jq (https://stedolan.github.io/jq/) is installed inside the minifabric cli container, the command <code>minifab stats</code> uses jq to retrieve the HTTP status code from the JSON response of the running containers. <code>minifab stats</code> is also invoked by <code>minifab up</code> and without the JSON response containing the OK feedback, the process exits.

### Chaincode Containers

Before installing the chaincode (your own or the simpleCC) with <code>minifab install</code> it is necessary to set the core chaincode builder in the spec.yaml as described here [working with customised chaincode builders](https://github.com/hyperledger-labs/minifabric/blob/main/docs/README.md#working-with-customised-chaincode-builders).
	
```
fabric:
  settings:
    peer:
      CORE_CHAINCODE_BUILDER: hyperledger/fabric-ccenv:my2.2
```

Depending on your chaincode language it may be required to set the <code>CORE_CHAINCODE_NODE_RUNTIME</code> parameter as well.

## Considerations for ARMHF

TLDR consider using the ARM64 architecture. When running minifabric on ARMHF you may experience segmentation faults caused by code written in go.

```
panic: runtime error: invalid memory address or nil pointer dereference,
[signal SIGSEGV: segmentation violation code=0x1 addr=0x4 pc=0x5273d8],
goroutine 45 [running]:,
github.com/hyperledger/fabric/gossip/identity.(*storedIdentity).fetchIdentity(0x3f058c0, 0x3a1, 0x3a1, 0x1),
	/go/src/github.com/hyperledger/fabric/gossip/identity/identity.go:261 +0xa0,
```

Function calls such as, <code>atomic.storeInt64();</code>
(https://github.com/hyperledger/fabric/blob/v2.2.0/gossip/identity/identity.go#L261) are causing this segmentation fault. The problem is related to the 64-bit alignment of 64-bit words accessed atomically, as described here [#23345](https://github.com/golang/go/issues/23345). Since Hyperledger Fabric holds numerous unaligned structs, there is no quick fix for this issue. Therefore, using a 64-bit architecture instead is recommended (e.g. raspios-bullseye-arm64).
