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

### Get the script and make it executable.

#### If you have either Linux or OS X system
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minifab -sL https://tinyurl.com/twrt8zv && chmod +x minifab
```

#### If you have a windows system
```
mkdir %userprofile%\mywork & cd %userprofile%\mywork & curl -o minifab.cmd -sL https://tinyurl.com/yb3ouwm3
```

### Stand up a fabric network:

#### For Linux or OS X
```
./minifab up
```

#### For Windows
```
minifab up
```

### Tear down the fabric network when you do not need it any more:
#### For Linux or OS X
```
./minifab down
```

#### For Windows 10
```
minifab down
```

Notes: If you are using windows system, command line parameter using double
quotes will have to be replaced with \". For example:
注意: 如果你使用Windows系统，命令行参数中所有双引号必须使用\"来代替。比如：
```
  minifab invoke -p '"invoke","a","b","4"'
```
must be changed to the following:
```
  minifab invoke -p \"invoke\",\"a\",\"b\",\"4\"
```
