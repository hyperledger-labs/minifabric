# Minifabric
If you like to experience Hyperledger Fabric or develop your smart contract,
Minifabric is the tool to start. It does not matter if you just have
a small server or you have multiple servers, Minifabric will help you stand
up your Fabric network on a single server or cross multiple servers within
few minutes. Minifabric is small but it allows you to experience the full
capabilities of Hyperledger Fabric. All you need is a docker environment. If
you like to explore what you can do with it, please read [Minifabric User Guide](https://github.com/litong01/minifabric/blob/master/docs/README.md). For those impatient, please follow the steps
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

