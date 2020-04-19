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
10. Channel configuration query, configuration signing and configuration update
11. Private data collection support
12. Generate connection profiles and wallet files for fabric go/python sdks and vscode extensions

### Prerequsites
This tool requires docker CE 18.03 or newer regardless which system you are using

### Get the script and make it executable
```
curl -o minifab -L https://tinyurl.com/twrt8zv && chmod +x minifab
```

It is highly recommended that you move script `minifab` into a directory which is part
of your $PATH such as ~/.local/bin to save time since this file does not change often.

### Create a working directory
Create a directory with any name you prefer and change to that directory. This directory
becomes your working directory, all minifab commands should be executed in this directory.

### Stand up a fabric network:
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

### Tear down the fabric network:
```
minifab down
minifab cleanup
```
The first command simply removes all the docker containers which make up the fabric network. The seoncd command remove all the containers and cleanup the working directory

### The normal process of dealing with Hyperledger Fabric
Working with Hyperledger Fabric can be intimidating at first, this section is to show you the normal process of working with Fabric.

    1. Stand up a fabric network
    2. Create a channel
    3. Join peers to a channel
    4. Install chaincode onto peers
    5. Approve chaincode (only for 2.0)
    6. Commit or instantiate chaincode
    7. Invoke chaincode (using either minifab or your applications)
    8. Query blocks
    
Then you may perform some more advanced operations such as channel query, channel update signoff, channel update. If you have multiple minifabric created Fabric network, you can even use the minifab dashboard to join all them together to make a bigger Fabric network.

### Setup a network using a different spec
Simply download this [spec](https://github.com/litong01/minifabric/blob/master/spec.yaml) and make changes to what you like, then run the following command in a directory where your new spec.yaml file is:

```
minifab up
```

### To install your own chaincode
Create the following subdirectory in your working directory:
  
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

When you develop your own chaincode for 1.4.x, it is important to place all your code in one package since Fabric 1.4.x
uses go 1.12.12 whose support to mod module is not complete, code in the subdirectory can not be picked up. For fabric 2.0
or greater, it is supported, you can have some local modules with your own chaincode. If you are in a location which is hard to access golang related public repository, you can package your chaincode with the vendor directory which already includes all necessary dependencies, this way, during the install, minifabric wont try to get the dependencies again.

If you have no chaincode developed and run `minifab install` command, minifab will install the sample chaincode named `simple` which comes with minifab.

### To upgrade your chaincode
If you have changed your chaincode and like to upgrade the chaincode on
this fabric network, you simply need to do the install with a newer
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
take last time. In 2.0.0 or newer release, you will also need to approve the chaincode before you instantiate like this:

```
minifab approve
```

### To invoke chaincode methods
Minifab utilizes the -p parameter to invoke a chaincode method. The -p parameter should include the method name and its parameters, minifab invoke command should follow this format:

```
minifab invoke -n chaincodename -p '"methodname","p1","p2",...'
```

Since chaincode invocation very much depends on how the chaincode methods were developed, it is important to know the method before you actually try to invoke it. The following two examples invoke the `simple` chaincode `invoke` and `query` methods:

```
minifab invoke -n simple -p '"invoke","a","b","5"'
minifab invoke -p '"query","a"'
```

### Query blocks
Minifab allows you easily query your ledger. To get the latest block and contained transactions, you just need to run the following commands:

```
minifab blockquery
minifab blockquery -b newest
minifab blockquery -b 6
```

The first two commands do the same thing and will retrieve the latest block. The last command will retrieve the block number 7 (notice the first block is 0)

### Update channel configuration
To update channel configuration, follow these steps:

```
   minifab channelquery
```

The above command will produce a channel configuration json file in vars directory, the name of the file will be
`<channel_name>_config.json`, once you see that file, you can go ahead make changes to the file. If you are satsified with
the changes, execute the following command

```
   minifab channelsign,channelupdate
```
The above command will sign off the channel configuration update using all the orgs admin credentials and then submit the
channel configuration update transaction. When it is all finished successfully, you can do another channelquery to see the
changes take affects.

### To add a new organization to your Fabric network
To add a new organization to your network takes few steps, please follow the below steps:
```
1. minifab install,approve,commit -n cmcc
2. minifab dashup -o org0.example.com
```

The step #2 will provide you a port, you can access the Consortium Dashboard at the public IP address of the machine and the port, for example, if your server's IP is 192.168.56.23, and the port showing in the step #2 is 7060, then you can access it at http://192.168.56.32:7060. Once you see the dashboard, you can create proposal. When you try to create a proposal, you will need to upload a join request json file. The good news is that if you already setup an organization somewhere else using minifabric, you will find join request file in vars directory using a name like this JoinRequest_org0examplecom.json, notice the file name starts JoinRequest, then the organizations MSPID. It is a json file. If your new organization is not created by minifabric, you will have to manually create this file, this file is a typical Fabric channel configuration file which contains pieces information about your network and certificates. You should use the file created in the vars directory as an example to manually create a similar file for your fabric network. Once you have the proposal created on the dashboard, you will need to possibly bring up the other organization's dashboard to sign the proposal. Once the proposal gets signed by enough organization admins, then one of the admins will be able to click on the Apply button from the dashboard to submit the proposal. Once it is all done without errors, then the new org is now part of the your Fabric network. The new org admin will be able to join their peers to the channel.


### Execution context
Minifab uses many settings throughout all the operations. These settings can be changed any time you run a minifab command and these settings will be saved in the vars/envsetting file. Each time a command is executed, that file will be loaded and settings specified in the command line will be written into that file. All the settings saved and specified in the command  make the current execution context. They include chaincode name, chaincode invocation parameter, chaincode version, chaincode language, channel name, fabric release, endpoint exposure and block query number. 

All the default values are set by [envsettings](https://github.com/litong01/minifabric/blob/master/envsettings). Each of the values get updated if specified in commands and saved back to `./vars/envsettings`. Users strongly discouraged to manually change that file since it is basically a program. Changes to that file should have been made by minifab.

Because of the execution context, when you execute a command, you do not really have to specify all the parameters necessary if the context do not need to be changed. For example, if you just executed a chaincode invoke command, and you like to execute invoke again, then you do not really need to specify the -n parameter since it is already in the current execution context. Same thing applies to every parameter listed in that file. You do not need to specify the parameter in a command unless you intend to use a new value in your command, once you do, the new value becomes part of the current execution context. 

### Update minifabric
Minifabric development goes very fast. It is always a good idea to refresh your minifabric once in awhile by simply run the following script
```
curl -o minifab -L https://tinyurl.com/twrt8zv && chmod +x minifab
docker pull hfrd/minifab:latest
```


### See more available fabric commands
```
minifab
```

### Windows system users

If you are using windows system, command line parameters which contain double
quotes will have to be replaced with `\"`. For example:

In Linux and OS X, you may have a command like this
```
minifab invoke -p '"invoke","a","b","4"'
```
It will have to be changed to the following for windows:
```
minifab invoke -p \"invoke\",\"a\",\"b\",\"4\"
```

### For the people who has trouble to download images from docker hub
Minifabric uses hyperledger offical docker images from docker hub. It will automatically pull these images when it needs them. For people who lives outside of the US, pulling images may be extremely slow or nearly impossible. To avoid breakages due to the image pulling issues, you may pull the following images from other docker repository or use different means to pull these images for example, writing your own script to pull images over night. As long as these images exist on your machine, minifab wont pull them again. To help you to do this, here is a list of images in case you like to pull them use other means.

#### Fabric 2.0
```
hfrd/minifab:latest
hfrd/cmdash:latest
hyperledger/fabric-tools:2.0
hyperledger/fabric-peer:2.0
hyperledger/fabric-orderer:2.0
hyperledger/fabric-ccenv:2.0
hyperledger/fabric-baseos:2.0
hyperledger/fabric-ca:1.4
hyperledger/fabric-couchdb:latest
```

#### Fabric 1.4 which is an alias to 1.4.5
```
hfrd/minifab:latest
hfrd/cmdash:latest
hyperledger/fabric-ca:1.4
hyperledger/fabric-tools:1.4
hyperledger/fabric-ccenv:1.4
hyperledger/fabric-orderer:1.4
hyperledger/fabric-peer:1.4
hyperledger/fabric-couchdb:latest
hyperledger/fabric-baseos:amd64-0.4.18
```

For other Fabric releases which is equal to or greater than 1.4.1, replace the tag accordingly.
