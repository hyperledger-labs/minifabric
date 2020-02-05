# Minifabric
This tool helps Fabric users working with fabric network. It currently provides the following functions:

1. Deploy a fabric network based on this [spec](https://github.com/litong01/minifabric/blob/master/spec.yaml) or your own spec
2. Tear down the deployed fabric network
3. Create channel
4. Join peers to a channel
5. Install sample chaincode or your own chaincode
6. Upgrade chaincode
7. Approve and instantiate chaincode
8. Invoke chaincode methods
9. Query blocks and transactions
10. Channel configuration query, configuration update and configuration signing
11. Transaction query
12. Consortium management dashboard

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

# To invoke chaincode methods
Minifab utilizes the -p parameter to invoke a chaincode method. The -p parameter should include the method name and its parameters, minifab invoke command should follow this format:

```
minifab invoke -n chaincodename -p '"methodname","p1","p2",...'
```

Since chaincode invocation very much depends on how the chaincode methods were developed, it is important to know the method before you actually try to invoke it. The following two examples invoke the `simple` chaincode `invoke` and `query` methods:

```
minifab invoke -n simple -p '"invoke","a","b","5"'
minifab invoke -p '"query","a"'
```

# Query blocks
Minifab allows you easily query your ledger. To get the latest block and contained transactions, you just need to run the following commands:

```
minifab blockquery
minifab blockquery -b newest
minifab blockquery -b 6
```

The first two commands do the same thing and will retrieve the latest block. The last command will retrieve the block number 7 (notice the first block is 0)

# Execution context
Minifab uses many settings throughout all the operations. These settings can be changed any time you run a minifab command and these settings will be saved in the vars/envsetting file. Each time a command is executed, that file will be loaded and settings specified in the command line will be written into that file. All the settings saved and specified in the command  make the current execution context. They include chaincode name, chaincode invocation parameter, chaincode version, chaincode language, channel name, fabric release, endpoint exposure and block query number. 

All the default values are set by [envsettings](https://github.com/litong01/minifabric/blob/master/envsettings). Each of the values get updated if specified in commands and saved back to `./vars/envsettings`. Users strongly discouraged to manually change that file since it is basically a program. Changes to that file should have been made by minifab.

Because of the execution context, when you execute a command, you do not really have to specify all the parameters necessary if the context do not need to be changed. For example, if you just executed a chaincode invoke command, and you like to execute invoke again, then you do not really need to specify the -n parameter since it is already in the current execution context. Same thing applies to every parameter listed in that file. You do not need to specify the parameter in a command unless you intend to use a new value in your command, once you do, the new value becomes part of the current execution context. 
