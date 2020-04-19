# Minifabric

[中文说明](./README.zh.md)

If you like to learn Hyperledger Fabric or develop your smart contract, or
just want to get a feel about Hyperledger Fabric, Minifabric is the tool to
get you started. Minifabric can stand up a Fabric network on a small machine
like a VirtualBox VM but also can deploy Fabric networks cross multiple production
grade servers. Minifabric is small but it allows you to experience the full
capabilities of Hyperledger Fabric. You will be able to try all Fabric operations
such as channel create, channel join, chaincode install, approve, instantiation.
It also supports channel update, private data collection, block query etc.
All you need to start with is a [docker](https://www.docker.com/) (18.03 or newer) environment. Minifabric works on Linux, OS X and Windows. If you like to read more before jumping in, please read [Minifabric User Guide](https://github.com/litong01/minifabric/blob/master/docs/README.md). For those impatient, please follow the steps
below to start things off.

### 1. Get the script.

##### Run the following command for Linux or OS X
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minifab -sL https://tinyurl.com/twrt8zv && chmod +x minifab
```

##### Run the following command for windows 10
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

### 4. To learn other minifab fucntions:
```
minifab
```