# Minifabric
This tool helps Fabric users working with fabric network. It currently provides the following functions:

1. Deploy a fabric network based on this [spec](https://github.com/litong01/minifabric/blob/master/spec.yaml) or your own spec
2. Tear down the deployed fabric network
3. Create channel
4. Join peers to a channel
5. Install sample chaincode or your own chaincode
6. Upgrade chaincode
7. Instantiate chaincode
8. Invoke chaincode methods
9. Channel configuration query, configuration update and configuration signing
10. Consortium management dashboard

# Prerequsites
This tool requires docker CE 18.03 or newer.

# Get the script and make it executable
```
curl -o minifab -L https://tinyurl.com/twrt8zv && chmod +x minifab
```

You can also move script `minifab` into a directory which is part
of your $PATH such as ~/.local/bin to save time

# Stand up a fabric network:
```
minifab up
```

When it finishes, you should have a fabric 2.0.0 network running on your machine.
You will also have an application channel named `mychannel` created, all
peers defined in the spec joined into that channel, and a chaincode named
`simple` being installed and instantiated.

If you like to use different version of fabric, simply specify the version using -i
flag like below

```
minifab up -i 1.4.4
```

Minifabric supports fabric version 1.4.1 and newer. If you switch between fabric
versions, you will need to run `minifab generate -i` command between your `minifab up -i`
commands to ensure certs and channel artifacts regenerated correctly. For example:

```
minifab up -i 1.4.2
minifab down
minifab generate -i 2.0.0
minifab up
```

Notice that there is a `minifab generate` command called between two minifab up commands

# See more available fabric operations
```
minifab
```

# Tear down the fabric network:
```
minifab down
```

# Setup a network using a different spec
Simply download this [spec](https://github.com/litong01/minifabric/blob/master/spec.yaml) and make changes to what you like, then run the following
command in a directory where your new spec.yaml file is:

```
minifab up
```

# To install your own chaincode
Create the following directory:
  
```
mkdir -p $(pwd)/vars/chaincode/<chaincodename>/go
```
where `<chaincodename>` should be the name you give to your chaincode

Place your code in that directory, then do the following
```
minifab install -n <chaincodename> -v 1.0
```
If your chaincode is written in node or java, your code should go to the following directories respectively
```
$(pwd)/vars/chaincode/<chaincodename>/node
$(pwd)/vars/chaincode/<chaincodename>/java
```

If you have no chaincode developed and run `minifab install` command, minifab will install the sample chaincode named simple which comes with minifab.

# To upgrade your chaincode
If you have changed your chaincode and like to upgrade the chaincode on
the fabric network, you simply need to do the install with a newer
version number, for example:
```
minifab install -n simple -v 2.0
```
Once it is finished successfully, then you just need to call the
instantiate command again like this
```
minifab instantiate
```

Since you specified the name and version during the install, you
do not have to specify again, minifab remembers what action was
take last time.
