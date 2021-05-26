# Known Issues
This document lists the known issues that you may experience after you install the minifabric.

### ISSUE:

Error: chaincode install failed with status: 500 - failed to invoke backing implementation of 'InstallChaincode'

### ENVIRONMENT: 

Mac with Intel Chip / MacOS Big Sur 11.3.1 / Docker 20.10.6

### SOLUTION:

- Launch Docker Dashboard
- Open Preferences
- Click Experimental Features
- Disable Use gRPC FUSE for file sharing
- Apply / Restart

### Related issue(s): [#214](https://github.com/hyperledger-labs/minifabric/issues/214)  [#87](https://github.com/hyperledger-labs/minifabric/issues/87)
