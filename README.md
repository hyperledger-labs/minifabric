# Minifabric 

![MiniFab CI](https://github.com/hyperledger-labs/minifabric/workflows/MiniFab%20CI/badge.svg)
[![Chat](https://raw.githubusercontent.com/hyperledger/chat-assets/main/fabric-mini.svg)](https://chat.hyperledger.org/channel/fabric-mini)

[中文](https://github.com/hyperledger-labs/minifabric/blob/main/README.zh.md)

If you would like to learn Hyperledger Fabric or develop your smart contract, or
just want to get a feel of Hyperledger Fabric, Minifabric is the tool to
get you started. Minifabric can stand up a Fabric network on a small machine
like a VirtualBox VM but can also deploy Fabric networks across multiple production
grade servers. Minifabric has been tested on Linux, OS X, Windows 10 and supports
Fabric releases 1.4.4 or newer.

## Feature Highlight

Minifabric is small but it allows you to experience the full
capabilities of Hyperledger Fabric.

- Fabric network setup and expansion such as adding new organizations
- channel query, create, join, channel update
- chaincode install, approve, instantiation, invoke, query and private data collection
- ledger height and block query and Hyperledger Explorer support
- node monitoring, health check and discovery
- never pollute your environment

## Prerequisites
[docker](https://www.docker.com/) (18.03 or newer) environment

5 GB remaining Disk Storage available
## Getting Started    

If you would like to learn more before jumping in, watch the [series of 6 videos](https://www.youtube.com/playlist?list=PL0MZ85B_96CExhq0YdHLPS5cmSBvSmwyO) on how to develop Hyperledger Fabric using Minifabric and read the [blog](https://www.hyperledger.org/blog/2020/04/29/minifabric-a-hyperledger-fabric-quick-start-tool-with-video-guides). For those impatient, please follow the steps below to start things off.

### 1. Get the script.

##### If you are using Linux (Ubuntu, Fedora, CentOS), or OS X
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minifab -sL https://tinyurl.com/yxa2q6yr && chmod +x minifab
```

##### If you are using Windows 10
```
mkdir %userprofile%\mywork & cd %userprofile%\mywork & curl -o minifab.cmd -sL https://tinyurl.com/y3gupzby
```

##### Make minifab available system wide

Move the minifab (Linux and OS X) or minifab.cmd (Windows) script to a directory which is part of your execution PATH in your system or add the directory containing it to your PATH. This is to make the later operations a bit easier, you will be able to run the minifab command anywhere in your system without specifying the path to the minifab script.

### 2. Stand up a fabric network:

```
minifab up
```

### 3. Tear down the fabric network and cleanup everything:
```
minifab cleanup
```

### 4. To learn other minifab functions:
```
minifab
```

## Documents
To know more about MiniFabric, see in [docs](./docs/README.md)

## known issues
To know more details, see in [KnownIssues](./docs/KnownIssues.md)
