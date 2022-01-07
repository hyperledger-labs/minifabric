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
(https://github.com/hyperledger/fabric/blob/v2.2.0/gossip/identity/identity.go#L261) and is related to the 64-bit alignment of 64-bit words accessed atomically, as described here (golang/go#23345 (comment)). Since Hyperledger Fabric holds numerous unaligned structs, there is no quick fix for this issue. Therefore, 64-bit architecture is recommended (e.g. raspios-bullseye-arm64).

With this configuration and some small adjustments (like a missing jq installation in the cli container) we had success and were able to run minifabric.


Run the following commands
```
Terminal
```

## Considerations for ARM64
Text... (jq installieren, chaincode images)
```
Terminal
```

Compatible sample images can be found on dockerhub LINK
and to simply build your own images, refer to the following sources LINK.