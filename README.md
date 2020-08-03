# Minifabric 

[![Build Status](https://dev.azure.com/Hyperledger/Cello/_apis/build/status/litong01.minifabric?branchName=master)](https://dev.azure.com/Hyperledger/Cello/_build/latest?definitionId=107&branchName=master)

[中文](https://github.com/litong01/minifabric/blob/master/README.zh.md)

If you like to learn Hyperledger Fabric or develop your smart contract, or
just want to get a feel about Hyperledger Fabric, Minifabric is the tool to
get you started. Minifabric can stand up a Fabric network on a small machine
like a VirtualBox VM but also can deploy Fabric networks cross multiple production
grade servers. Minifabric has been tested on Linux, OS X, Windows 10 and supports
Fabric releases 1.4.1 or newer.

## Feature Highlight

Minifabric is small but it allows you to experience the full
capabilities of Hyperledger Fabric.

- Fabric network setup and expansion such as adding new organizations
- channel query, create, join, channel update
- chaincode install, approve, instantiation, invoke, query and private data collection
- ledger height and block query
- node monitoring, health check and discovery

## Prerequisites
[docker](https://www.docker.com/) (18.03 or newer) environment
 
## Getting Started    

If you like to learn more before jumping in, Watch the [series of 6 videos](https://www.youtube.com/playlist?list=PL0MZ85B_96CExhq0YdHLPS5cmSBvSmwyO) on how to develop Hyperledger Fabric using Minifabric and read the [blog](https://www.hyperledger.org/blog/2020/04/29/minifabric-a-hyperledger-fabric-quick-start-tool-with-video-guides). For those impatient, please follow the steps below to start things off.

### 1. Get the script.

##### If you are using Linux, OS X, or Windows 10 with WSL2
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minifab -sL https://tinyurl.com/twrt8zv && chmod +x minifab
```

##### If you are using Windows 10 without WSL2 installed
```
mkdir %userprofile%\mywork & cd %userprofile%\mywork & curl -o minifab.cmd -sL https://tinyurl.com/yb3ouwm3
```

##### Make minifab available system wide

Move the minifab (Linux and OS X) or minifab.cmd (Windows) script to a directory which is part of your execution path in your system, this is to make the later operations a bit easier, you will be able to run minifab command anywhere in your system without specify the path to the minifab script.

### 2. Stand up a fabric network:

```
minifab up
```

### 3. Tear down the fabric network:
```
minifab down
```

### 4. To learn other minifab functions:
```
minifab
```
