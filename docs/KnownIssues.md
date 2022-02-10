# Known Issues
This document lists the known issues that you may experience during operation of minifabric.

### Chaincode Installation
1. [Error installing chaincode](#1)

### Kubernetes
1. [Service Endpoint Error](#2)

****
### ISSUE:

<a name="1"></a>Error: chaincode install failed with status: 500 - failed to invoke backing implementation of 'InstallChaincode'

### ENVIRONMENT:

Mac with Intel Chip / MacOS Big Sur 11.3.1 / Docker 20.10.6

### SOLUTION:

- Launch Docker Dashboard
- Open Preferences
- Click Experimental Features
- Disable Use gRPC FUSE for file sharing
- Apply / Restart

### Related issue(s): [#214](https://github.com/hyperledger-labs/minifabric/issues/214)  [#87](https://github.com/hyperledger-labs/minifabric/issues/87)

****

### ISSUE:

<a name="2"></a>ServiceEndpoint Error: Failed to connect to remote gRPC server x.x.x.x:xxxx, url:grpcs://localhost:xxxx

### ENVIRONMENT:

Kubernetes / K8S

### SOLUTION:

When connecting to the fabric network deployed in Kubernetes/K8S cluster using the minifabric generated connection profiles with Fabric SDK, make sure to double check that the **GatewayOptions.discovery asLocalhost = false** as shown below (otherwise if set to **true**, the SDK will be forced to use **localhost** when discovering peers/orders).
```
 GatewayOptions = {
  wallet,
  identity: ca_admin,
  discovery: { enabled: true, asLocalhost: false }
}
```
### Related issue(s): [#215](https://github.com/hyperledger-labs/minifabric/issues/215)

****

### ISSUE:

<a name="2"></a>The file contains an identity that already exists.
### ENVIRONMENT:

fabric-operations-console - Docker or K8S
Any Platform - Linux or Mac or Windows

### SOLUTION:

When trying to import assets.zip file as part of fabric operations console deployment in Minifabric, a non-first time, you may encounter this error message and fail to perform importing of zip file successfully.

The work-around is to navigate to Wallet option on the same console, delete identities already stored in the browser web storage and performing the re-import of assets.zip file.

The reason this error appears is due to the identities remaining in browser web storage and conflicting/name clashing with same artifacts already in web storage.

### Related issue(s): 
