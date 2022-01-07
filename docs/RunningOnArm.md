# Running minifabric on ARM

This document lists the known issues that you may experience trying to operate minifabric on ARM hardware. 
Related issue(s): [#293](https://github.com/hyperledger-labs/minifabric/issues/293)

## General considerations

Running minifabric on armhf you may experience segmentation faults caused by code written in go.

```
panic: runtime error: invalid memory address or nil pointer dereference,
[signal SIGSEGV: segmentation violation code=0x1 addr=0x4 pc=0x5273d8],
goroutine 45 [running]:,
github.com/hyperledger/fabric/gossip/identity.(*storedIdentity).fetchIdentity(0x3f058c0, 0x3a1, 0x3a1, 0x1),
	/go/src/github.com/hyperledger/fabric/gossip/identity/identity.go:261 +0xa0,
```

The segmentation fault occurs when calling the function "atomic.storeInt64()"
(https://github.com/hyperledger/fabric/blob/v2.2.0/gossip/identity/identity.go#L261) and is related to the 64-bit alignment of 64-bit words accessed atomically, as described here (golang/go#23345 (comment)). Since Hyperledger Fabric holds numerous unaligned structs, there is no quick fix for this issue. Therefore, using a 64-bit architecture is recommended (e.g. raspios-bullseye-arm64).

## Considerations for ARM64

To run ARM64 docker images compatible with minifabric, make sure your images are fullfilling the following requirements.

###Cli container image

Make sure jq is installed inside the minifabric cli container, the command <code>minifab stats</code> uses jq to retrieve the HTTP status code from the response message of the running containers. <code>minifab stats</code> is also invoked by <code>minifab up</code> and without a OK feedback, the process exits.

###Chaincode containers

Beschreibung wie wir welchen chaincode cotainer zum laufen bekommen.


Compatible sample images can be found on dockerhub LINK
and to simply build your own images, refer to the following sources LINK.