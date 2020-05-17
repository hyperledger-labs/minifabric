# Minifabric
Minifabric is a tool to let you setup Fabric network, expand your network, install and upgrade your own chaincode, invoke transactions, inspect your ledger, change configurations of your channel. By going through these tasks using Minifabric, you can gain tremendous skills and a complete understanding of Hyperledger Fabric.

It currently provides the following functions:

1. Deploy a fabric network based on this [spec](https://github.com/litong01/minifabric/blob/master/spec.yaml) or your own spec
2. Tear down the deployed fabric network
3. Channel operations such as create, update, join peers to channels, channel update and channel query
4. Chaincode operations such as install, approve, commit, upgrade, initialize, instantiate, invoke and query
5. Query blocks and transactions
6. Private data collection support
7. Generate connection profiles and wallet files for fabric go/python sdks and vscode extensions
8. Fabric node health and metrics enabled

The table of the content
========================
1. [Prerequsites](#prerequsites)
2. [Working directory](#working-directory)
3. [Stand up a Fabric network](#stand-up-a-fabric-network)
4. [Tear down the fabric network](#tear-down-the-fabric-network)
5. [The normal process of working with Hyperledger Fabric](#the-normal-process-of-working-with-hyperledger-fabric)
6. [Setup a network using a different spec](#setup-a-network-using-a-different-spec)
7. [To install your own chaincode](#to-install-your-own-chaincode)
8. [To upgrade your chaincode](#to-upgrade-your-chaincode)
9. [To invoke chaincode methods](#to-invoke-chaincode-methods)
10. [Query blocks](#query-blocks)
11. [Update channel configuration](#update-channel-configuration)
12. [To add a new organization to your Fabric network](#to-add-a-new-organization-to-your-fabric-network)
13. [Check node health and metrics](#check-node-health-and-metrics)
14. [Execution context](#execution-context)
15. [Update minifabric](#update-minifabric)
16. [See more available Minifabric commands](#see-more-available-minifabric-commands)
17. [Minifabric videos](#minifabric-videos)
### Prerequsites
This tool requires **docker CE 18.03** or newer, Minifabric supports Linux, OS X and Windows 10

### Get the script and make it available system wide
##### Run the following command for Linux or OS X
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minifab -sL https://tinyurl.com/twrt8zv && chmod +x minifab
```
##### Run the following command for windows 10
```
mkdir %userprofile%\mywork & cd %userprofile%\mywork & curl -o minifab.cmd -sL https://tinyurl.com/yb3ouwm3
```
##### Make minifab available system wide
Move the minifab (Linux and OS X) or minifab.cmd (Windows) script you just downloaded to a directory which is part of your execution path in your system, this is to make Minifabric executions a bit easier, you will be able to run minifab command anywhere in your system without specify the path to the minifab script. When word Minifabric is used, it refers to this tool, when word minifab is used, it refers to Minifabric command which is the only command Minifabric has.

### Working directory
A working directory is a directory where all Minifabric commands should run from. It can be any directory in your system, Minifabric will create running scripts, templates, intermediate files in a subdirectory named vars in this working directory. This is the directory that you can always go to to see how Minifabric get things done. Create a directory with any name you prefer and change to that directory when you start running Minifabric commands. In all Minifabric document, we use `~/mywork` as the working directory, anywhere referring to that directory means your own working directory, it does not mean you have to use that directory as your working directory.

### Stand up a Fabric network:

To stand up a Fabric network, simply run `minifab up` command in your working directory. When the command finishes, you should have a Fabric network running normally using the latest Fabric release (currently 2.1.0) on your machine. You will also have an application channel named `mychannel` created, all peers defined in the network spec file joined into that channel, and a chaincode named `simple` installed and instantiated. This command is the command to use if you simply want to stand up a fabric network with channel and chaincode all ready for business. Since it executes majority of a Fabric network operations, the process will take a bit of time. It should normally completes in about 4 minutes giving that you have a good internet connection.

If you like to use different version of fabric, simply specify the version using -i
flag like below

```
minifab up -i 1.4.4
```

Minifabric supports fabric release 1.4.1 and newer. If you like to switch to another fabric release, you will need to run `minifab cleanup` command, then `minifab up -i x.x.x`
commands to ensure certs and channel artifacts regenerated correctly. For example:

```
minifab up -i 1.4.2
minifab cleanup
minifab up -i 2.0.0
```

### Tear down the fabric network:
You can use one of the two commands below to shut down Fabric network.
```
minifab down
minifab cleanup
```
The first command simply removes all the docker containers which make up the fabric network, it will NOT remove any certificates or ledger data, you can run `minifab netup` later to restart the whole thing including chaincode containers if there are any. The seoncd command remove all the containers and cleanup the working directory

### The normal process of working with Hyperledger Fabric
Working with Hyperledger Fabric can be intimidating at first, the below list is to show you the normal process of working with Fabric.

    1. Stand up a fabric network
    2. Create a channel
    3. Join peers to a channel
    4. Install chaincode onto peers
    5. Approve chaincode (only for 2.0)
    6. Commit or instantiate chaincode
    7. Invoke chaincode (using either minifab or your applications)
    8. Query blocks
    
If you successfully complete each of the tasks in the list, you basically have verified that your Fabric network is working correctly. After the completion of these tasks, you may perform some more advanced operations such as channel query, channel update signoff, channel update. If you have multiple minifabric created Fabric network, you can even use the minifab to join all them together to make a bigger Fabric network.

### Setup a network using a different spec
When you simply do `minifab up`, Minifabric uses the Minifabric provided Fabric network spec file to stand up a Fabric network. In many cases, you probably do not want that kind of the network, you probably want to use different organization names, node names, number of organizations, number of peers etc, to layout your own Fabric network, simply download this [spec](https://github.com/litong01/minifabric/blob/master/spec.yaml) file, place it in your working directory, then change it to what you like, then run the `minifab up` command. If you already have a Fabric network running on this machine, you will need to remove the running Fabric network to avoid any naming conflicts.

When you have your own network spec file, you can further customize your node by utilizing the setting
section of network spec file. You can have a `settings` section like the following in your spec file.
You can place any ca, peer, or orderer node configuration parameters under each node type.

```
  cas:
     ...
  peers:
     ...
  orderers:
     ...
  settings:
    ca:
      FABRIC_LOGGING_SPEC: ERROR
    peer:
      FABRIC_LOGGING_SPEC: INFO
    orderer:
      FABRIC_LOGGING_SPEC: DEBUG
```

### To install your own chaincode
To install your own chaincode, create the following subdirectory in your working directory:
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

When you develop your own chaincode for 1.4.x, it is important to place all your code in one package since Fabric 1.4.x uses go 1.12.12 whose support to mod module is not complete, code in the subdirectory can not be picked up. For fabric 2.0 or greater, it is supported, you can have some local modules with your own chaincode. If you are in a location which is hard to access golang related public repositories (like google hosted sites), you can package your chaincode with the vendor directory which already includes all necessary dependencies, during the install, minifabric wont try to get the dependencies again.

If you do not have any chaincode, you can still run `minifab install -n simple` command, Minifabric will install that sample chaincode, command `minifab up` installs that chaincode if you do not specify another chaincode.

### To upgrade your chaincode
If you have changed your chaincode and like to upgrade the chaincode, you can simply install the chaincode with a higher version number, for example:
```
minifab install -n simple -v 2.0
```
Once it is finished successfully, then you just need to call the instantiate command again like below for Fabric release 1.4.x or do approve, commit like you normally do for Fabric release 2.x.x
```
minifab instantiate
```

Since you specified the chaincode name and version during the install, you do not have to specify again, Minifabric remembers what action was take last time. Minifabric accomplishes this by using it Execution Context which will be explained later in this document.

### To invoke chaincode methods
Minifab utilizes the -p parameter to invoke a chaincode method. The -p parameter should include the method name and its parameters, minifab invoke command should follow this format:

```
minifab invoke -n chaincodename -p '"methodname","p1","p2",...'
```

Since chaincode invocation very much depends on how the chaincode methods were developed, it is important to know the method interface before you actually try to invoke it. The following two examples invoke the `simple` chaincode `invoke` and `query` methods:

```
minifab invoke -n simple -p '"invoke","a","b","5"'
minifab invoke -p '"query","a"'
```

Notice that the value for `-p` parameter will be most likely differ from a method to another, since Minifabric remembers each command parameters in the Execution Context, you can always omit a command parameter if the parameter for the next command should stay the same. But in other cases, you probably do not want them to be the same, for example, you want to invoke a method multiple times like the below:

```
minifab invoke -n simple -p '"invoke","a","b","3"'
minifab invoke -p '"invoke","a","b","24"'
```

The each command will need to provide a different value for `-p` parameter. Notice that the double quotes and single quote in the value, they are very important, not following this convention will most likely produce an error during the invocation. If you are doing this in a window environment, command line parameters which contain double quotes will have to be replaced with `\"`, the above two commands on windows will have to executed like the below, notice that all the single quote was removed:

```
minifab invoke -n simple -p \"invoke\",\"a\",\"b\",\"4\"
minifab invoke -p \"invoke\",\"a\",\"b\",\"24\"
```

### Query blocks
Minifab allows you easily query your ledger. To get the latest block and contained transactions, run the following commands:

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

1. Get channel configuration by running `minifab channelquery` command, this command will produce a file named `./vars/<channel_name>_config.json`
2. Find the JoinRequest file for the new organization which should have been produced by Minifabric when the new organization was also setup by Minifabric in `vars` under your working directory. if your network was not setup by Minifabric, then you should create this file by other means.
3. Edit the `<channel_name>_config.json` file and add the all content of the JoinRequest file to the channel configuration file, make sure that the new content is placed in parallel to the existing organizations.
4. Run 'minifab channelsign,channelupdate' command.

Once all the steps are done correctly, the new organization is now part of your channel. The admin of the new orgnization can now join their peers to that channel. The entire process was demostrated in this [video](https://www.youtube.com/watch?v=c1Ab57IrgZg&list=PL0MZ85B_96CExhq0YdHLPS5cmSBvSmwyO&index=5&t=3s), please watch the video for a demostration. 

### Check node health and metrics
When you use minifabric sets up your fabric network, Minifabric will enable peer and orderer node health and
metrics. Regardless you choose to expose endpoint or not, peer and orderer node health and metrics services are enabled. The service port will be always set to 7061 for peer and 7060 for orderer node. When you choose
to expose node endpoints, these port will be mapped to the external ports. A health and metrics service port
always be set to the node endpoint port plus 1000. For example, if your peer1 is at 9.8.7.6 and its external
port is set to 8051, then the health and metrics service port will be 9051. As mentioned in other part of
this document, you will have to make sure that the block of these ports on your host are available. With the
above example, you can access health and metrics at the following endpoints:

```
node:      9.8.7.6:8051
health:    9.8.7.6:9051/healthz
metrics:   9.8.7.6:9051/metrics
```

### Execution context
Minifab uses many settings throughout all the operations. These settings can be changed any time you run a minifab command and these settings will be saved in the vars/envsetting file. Each time a command is executed, that file will be loaded and settings specified in the command line will be written into that file. All the settings saved and specified in the command  make the current execution context. They include chaincode name, chaincode invocation parameter, chaincode version, chaincode language, channel name, fabric release, endpoint exposure and block query number. 

All the default values are set by [envsettings](https://github.com/litong01/minifabric/blob/master/envsettings). Each of the values gets updated if specified in a command and saved back to `./vars/envsettings`. Users are strongly discouraged to manually change that file since it is basically a script, changes to that file should have been made by minifab command.

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

### For the people who has trouble to download images from docker hub
Minifabric uses hyperledger offical docker images from docker hub. It will automatically pull these images when it needs them. For people who lives outside of the US, pulling images may be extremely slow or nearly impossible. To avoid breakages due to the image pulling issues, you may pull the following images from other docker repository or use different means to pull these images for example, writing your own script to pull images over night. As long as these images exist on your machine, minifab wont pull them again. To help you to do this, here is a list of images in case you like to pull them use other means.

##### Fabric 2.0
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

##### Fabric 1.4 which is an alias to 1.4.6
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

### Minifabric videos
If you like to learn more, please watch the [series of 6 videos](https://www.youtube.com/playlist?list=PL0MZ85B_96CExhq0YdHLPS5cmSBvSmwyO) on how to develop Hyperledger Fabric using Minifabric
