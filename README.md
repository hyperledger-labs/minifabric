# Minifabric
If you like to learn Hyperledger Fabric or develop your smart contract, or
just want to get a feel about Hyperledger Fabric, Minifabric is the tool to
get you started. Minifabric can stand up a Fabric network on a small machine
like a VirtualBox VM but also can deploy Fabric networks cross multiple production
grade servers. Minifabric is small but it allows you to experience the full
capabilities of Hyperledger Fabric. you will be able to try all Fabric operations
such as channel create, channel join, chaincode install, approve, instantiation.
It even supports channel update. All you need to start with is a docker environment.
If you read more before you jump in, please read [Minifabric User Guide](https://github.com/litong01/minifabric/blob/master/docs/README.md). For those impatient, please follow the steps
below to start things off.

### Get the script and make it executable
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minifab -sL https://tinyurl.com/twrt8zv && chmod +x minifab
```

### Stand up a fabric network:
```
./minifab up
```

### Tear down the fabric network when you do not need it any more:
```
./minifab down
```
