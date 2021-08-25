# Minifabric
Minifabric is a tool to let you setup a Fabric network, expand your network, install and upgrade your own chaincode, invoke transactions, inspect your ledger, change the configuration of your channel. By going through these tasks using Minifabric, you can gain tremendous skills and a complete understanding of Hyperledger Fabric.

It currently provides the following functions:

1. Deploy a fabric network based on this [spec](https://github.com/hyperledger-labs/minifabric/blob/main/spec.yaml) or [your own spec](#Setup-a-network-using-a-different-spec)
2. Tear down the deployed fabric network
3. Channel operations such as create, update, join peers to channels, channel update and channel query
4. Chaincode operations such as install, approve, commit, upgrade, initialize, instantiate, invoke and query
5. Query blocks and transactions
6. Private data collection support
7. Generate connection profiles and wallet files for fabric go/node/python SDKs and VS Code extensions
8. Fabric node health and metrics enabled
9. Integrated with Hyperledger Explorer and Caliper
10.Run Fabric applications which work with Fabric network

The table of the content
========================
1. [Prerequisites](#prerequisites)
2. [Working directory](#working-directory)
3. [Stand up a Fabric network](#stand-up-a-fabric-network)
4. [Tear down the fabric network](#tear-down-the-fabric-network)
5. [The normal process of working with Hyperledger Fabric](#the-normal-process-of-working-with-hyperledger-fabric)
6. [Setup a network using a different spec](#setup-a-network-using-a-different-spec)
7. [Install your own chaincode](#install-your-own-chaincode)
8. [Upgrade your chaincode](#upgrade-your-chaincode)
9. [Invoke chaincode methods](#invoke-chaincode-methods)
10. [Query blocks](#query-blocks)
11. [Update the channel configuration](#update-the-channel-configuration)
12. [Add a new organization to your Fabric network](#add-a-new-organization-to-your-fabric-network)
13. [Check node health and metrics](#check-node-health-and-metrics)
14. [Execution context](#execution-context)
15. [Working with customised chaincode builders](#working-with-customised-chaincode-builders)
16. [Update minifabric](#update-minifabric)
17. [See more available Minifabric commands](#see-more-available-minifabric-commands)
18. [Minifabric videos](#minifabric-videos)
19. [Build minifabric locally](#build-minifabric-locally)
20. [Hook up Explorer to your fabric network](#hook-up-explorer-to-your-fabric-network)
21. [Run your application quickly](#run-your-application-quickly)
22. [Run Caliper test](#run-caliper-test)
23. [Start up portainer web ui](#start-up-portainer-web-ui)
24. [Use Fabric operation console](#use-fabric-operation-console)

### Prerequisites
This tool requires **docker CE 18.03** or newer, Minifabric supports Linux, OS X and Windows 10

### Get the script and make it available system wide
##### Run the following command for Linux or OS X
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minifab -sL https://tinyurl.com/yxa2q6yr && chmod +x minifab
```
##### Run the following command for windows 10
```
mkdir %userprofile%\mywork & cd %userprofile%\mywork & curl -o minifab.cmd -sL https://tinyurl.com/y3gupzby
```
##### Make minifab available system wide
Move the minifab (Linux and OS X) or minifab.cmd (Windows) script you just downloaded to a directory which is part of your execution PATH in your system or add the directory containing it to your PATH. This is to make Minifabric executions a bit easier, you will be able to run the minifab command anywhere in your system without specify the path to the minifab script. When the term `Minifabric` is used, it refers to the tool, when the term `minifab` is used, it refers to the Minifabric command which is the only command Minifabric has.

### Working directory
A working directory is a directory where all Minifabric commands should run from. It can be any directory in your system, Minifabric will create running scripts, templates, intermediate files in a subdirectory named vars in this working directory. This is the directory that you can always go to to see how Minifabric gets things done. Create a directory with any name you prefer and change to that directory when you start running Minifabric commands. In all Minifabric documentation, we use `~/mywork` as the working directory however, it does not mean you have to use that directory as your working directory. If you use a different directory, simply replace any reference to this directory with your own.

### Stand up a Fabric network:

To stand up a Fabric network, simply run the `minifab up` command in your working directory. When the command finishes, you should have a Fabric network running normally using the latest Fabric release (currently 2.3.0) on your machine. You will also have an application channel named `mychannel` created, all peers defined in the network spec file joined into that channel, and a chaincode named `simple` installed and instantiated. This command is the command to use if you simply want to stand up a Fabric network with channel and chaincode all ready for business. Since it executes the majority of a Fabric network operations, the process will take around 4 minutes to complete if you have a reasonably good internet connection because the process will also download the Hyperledger Fabric official images from Docker Hub.

If you would like to use a different version of Fabric, simply specify the version using the -i flag as follows

```
minifab up -i 1.4.4
```

Minifabric supports Fabric release 1.4.1 and newer. If you would like to switch to another Fabric release, you will need to run the `minifab cleanup` command, then the `minifab up -i x.x.x`
command to ensure certs and channel artifacts are regenerated correctly. For example:

```
minifab up -i 1.4.2
minifab cleanup
minifab up -i 2.0.0
```

### Tear down the Fabric network:
You can use one of the two commands below to shut down the Fabric network.
```
minifab down
minifab cleanup
```
The first command simply removes all the docker containers which make up the Fabric network, it will NOT remove any certificates or ledger data, you can run `minifab netup` later to restart the whole thing including chaincode containers if there are any. The second command removes all the containers and cleanup the working directory.

### The normal process of working with Hyperledger Fabric
Working with Hyperledger Fabric can be intimidating at first, the below list is to show you the normal process of working with Fabric.

    1. Stand up a Fabric network
    2. Create a channel
    3. Join peers to a channel
    4. Install chaincode onto peers
    5. Approve chaincode (only for 2.0)
    6. Commit or instantiate chaincode
    7. Invoke chaincode (using either minifab or your applications)
    8. Query blocks
    
If you successfully complete each of the tasks in the list, you basically have verified that your Fabric network is working correctly. After the completion of these tasks, you may perform some more advanced operations such as channel query, channel update signoff, channel update. If you have multiple minifabric created Fabric networks, you can even use the minifab to join all them together to make a bigger Fabric network.

### Setup a network using a different spec
When you simply do `minifab up`, Minifabric uses the network spec file `spec.yaml` in the working directory to stand up a Fabric network. In many cases, you probably want to use different organization names, node names, number of organizations, number of peers etc, to layout your own Fabric network, 

> If you already have a Fabric network running on this machine, you will need to remove the running Fabric network to avoid any naming conflicts.

When you have your own network spec file, you can further customize your node by utilizing the setting
section of network spec file. 

You can have a `settings` section like the following in your spec file.

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

You can place any ca, peer, or orderer node configuration parameters under each node type.

- **Organization Name** for each node is the part of the domain name after the first dot (.)
- **mspid** for each Organization is the translated Organization Name by substituting every dot (.) with a dash (-)
- host **port** is generated as incremental sequences of starting port number (supplied in -e 7778)
    - The second port(`7061`) of peer will be mapped to host port of [1000 + mapped host port number of its first port(`7051`)]

For example, following is the result for default spec.yaml with `-e 7778`

> ca1.org0.example.com --> hostPort=7778
> ca1.org1.example.com --> hostPort=7779
> orderer1.example.com --> 0.0.0.0:7784->7050/tcp, 0.0.0.0:8784->7060/tcp   
> orderer2.example.com --> 0.0.0.0:7785->7050/tcp, 0.0.0.0:8785->7060/tcp   
> orderer3.example.com --> 0.0.0.0:7786->7050/tcp, 0.0.0.0:8786->7060/tcp   
> peer1.org0.example.com --> mspid = org0-example-com, organization name = org0.example.com, hostPort=7780, 8780
> peer2.org0.example.com --> mspid = org0-example-com, organization name = org0.example.com, hostPort=7781, 8781
> peer1.org1.example.com --> mspid = org1-example-com, organization name = org1.example.com, hostPort=7782, 8782
> peer2.org1.example.com --> mspid = org1-example-com, organization name = org1.example.com, hostPort=7783, 8783

In default, **docker network** is automatically generated based on the working directory. This ensures that two different working directories will result in two different docker networks. This allows you to setup multiple sites on the same machine to mimic multiple organizations across multiple machines.
You can assign specific docker network name by uncomment bellow line in spec.yaml file. This allows you to setup fabric capability on the existing docker network easily. If you have multiple sites on same machine, it will be necessary to have different name for each site to avoid network conflict.

```
  # netname: "mysite"
```

You can add options for starting containers by uncomment bellow line in spec.yaml file. you can specify any option which supported by 'docker run' command.
Note that the value specified by container_options will be added when minifabric starts all node type containers (CA, peer, orderer, cli) without distinction.
```
  # container_options: "--restart=always --log-opt max-size=10m --log-opt max-file=3"
```

### Install your own chaincode
To install your own chaincode, create the following subdirectory in your working directory:
```
mkdir -p $(pwd)/vars/chaincode/<chaincodename>/<lang>
```
where `<chaincodename>` should be the name you give to your chaincode, and `<lang>` should be language of your chaincode, either one of go, node or java.
Your code should be in the following directories respectively according to your chaincodename and its language.
```
$(pwd)/vars/chaincode/<chaincodename>/go
$(pwd)/vars/chaincode/<chaincodename>/node
$(pwd)/vars/chaincode/<chaincodename>/java
```
Place your code in that directory, then do the following
```
minifab ccup -n <chaincodename> -l <lang> -v 1.0
```

When you develop your own chaincode for 1.4.x, it is important to place all your code in one package because Fabric 1.4.x uses go 1.12.12 which does not fully support modules and code in subdirectories cannot be picked up. For Fabric 2.0 or greater, go modules are supported and you can have some local modules with your own chaincode. If you are in a location with no access to golang related public repositories (like Google's hosted sites), you can package your chaincode with a vendor directory which includes all necessary dependencies. During the install, Minifabric will not try to get the dependencies again.

If you do not have any chaincode, you can still run `minifab ccup -n simple` command, Minifabric will install that sample chaincode. The command `minifab up` installs that chaincode if you do not specify another chaincode.

In some areas, when you install a golang written chaincode, the dependencies cannot be pulled directly from Google's hosted sites. In that case, you
will most likely need to use goproxy to bypass these restrictions. You can do so by specifying an accessible goproxy in the spec.yaml file. The default spec.yaml
file has an example commented out, you can uncomment that line and use your own go proxy to install your golang written chaincode.

In the case of chaincode that uses private data, the install command should include the flag -r or
--chaincode-private set to true. 
```
minifab ccup -n <chaincodename> -l <lang> -v 1.0 -r true
```
Then minifab will generate a private data collection configuration file in the vars directory with
the format `<chaincodename>_collection_config.json`.  This file needs to be modified for the specific
requirements of your chaincode before proceeding to the approve, commit, and initialize steps.  
Alternatively, a pre-configured collection config file can be placed in the vars directory using the same
name format before the install, and minifab will use it instead of creating the default file.

### Upgrade your chaincode
you can simply install the chaincode with a higher version number, as below in following cases:
 - when you have changed your chaincode and would like to upgrade the chaincode installed to your Minifabric network
 - when chaincode installation procedure failed in some reason and you would like to try install the same chaincode again.

```
minifab ccup -v 2.0 [ -n simple ] [ -l go ]
minifab ccup -v 3.0 [ -n simple ] [ -l go ]
:
```

`minifab ccup` is actually the alias of the following commands. you can execute below separate commands in step by step
```
minifab install -v version [ -n <chaincodename> ] [ -l <lang> ] [ -r true ]
minifab approve
minifab commit
minifab initialize [ -p '"methodname","p1","p2",...' ]
minifab discover
minifab channelquery
```
instead of:
```
minifab ccup -v version [ -n <chaicnodename> ] [ -l <lang> ] [ -r true ] [ -p '"methodname","p1","p2",...' ]
```

### Invoke chaincode methods
Minifab utilizes the -p parameter to invoke a chaincode method. The -p parameter should include the method name and its parameters, the `minifab invoke` command should follow this format:

```
minifab invoke -n chaincodename -p '"methodname","p1","p2",...'
```

Since chaincode invocation very much depends on how the chaincode methods were developed, it is important to know the method interface before you actually try to invoke it. The following two examples invoke the `simple` chaincode `invoke` and `query` methods:

```
minifab invoke -n simple -p '"invoke","a","b","5"'
minifab invoke -p '"query","a"'
```

Notice that the value for the `-p` parameter will most likely differ from one method to another. Since Minifabric remembers each command parameters in the Execution Context, you can always omit a command parameter if the parameter for the next command remains the same. When you do not want them to be the same, simply specify them again on the command line with the `-p` parameter for each invocation like in the below example:

```
minifab invoke -n simple -p '"invoke","a","b","3"'
minifab invoke -p '"invoke","a","b","24"'
```

Notice the use of double quotes and single quotes, these are very important. Not following this convention will most likely produce an error during the invocation. If you are doing this in a Windows environment, command line parameters which contain double quotes will have to be replaced with `\"`. The above two commands on Windows will have to executed like the below, notice that all the single quotes were removed:

```
minifab invoke -n simple -p \"invoke\",\"a\",\"b\",\"4\"
minifab invoke -p \"invoke\",\"a\",\"b\",\"24\"
```

### Query blocks
Minifab allows you to easily query your ledger. To get the latest block and contained transactions, run the following commands:

```
minifab blockquery
minifab blockquery -b newest
minifab blockquery -b 6
```

The first two commands do the same thing and retrieve the latest block. The last command retrieves the block number 7 (notice the first block is 0)

### Update the channel configuration
To update the channel configuration, follow these steps:

```
   minifab channelquery
```

The above command will produce a channel configuration JSON file in the vars directory. The name of the file will be
`<channel_name>_config.json`. Once you find that file, you can go ahead and make changes to the file. When you are satisfied with the changes, execute the following command:

```
   minifab channelsign,channelupdate
```
The above command will sign off the channel configuration update using all the orgs admin credentials and then submit the
channel configuration update transaction. When it is all finished successfully, you can do another `channelquery` to see the
changes take affects.

### Add a new organization to your Fabric network
To add a new organization to your network please follow the below steps:

1. Get the channel configuration by running the `minifab channelquery` command. This command will produce a file named `./vars/<channel_name>_config.json`
2. Find the JoinRequest file for the new organization which should have been produced by Minifabric when the new organization was setup by Minifabric in `vars` under your working directory. If your network was not setup by Minifabric, then you should create this file by other means.
3. Edit the `<channel_name>_config.json` file and add all the content of the JoinRequest file to the channel configuration file. Make sure that the new content is placed in parallel to the existing organizations.
4. Run the 'minifab channelsign,channelupdate' command.

Once all the steps are done correctly, the new organization is now part of your channel. The admin of the new organization can now join their peers to that channel. You may find [the video demonstrating how to add a new organization to a network](https://www.youtube.com/watch?v=c1Ab57IrgZg&list=PL0MZ85B_96CExhq0YdHLPS5cmSBvSmwyO&index=5&t=3s) helpful. 

### Check node health and metrics
When Minifabric sets up your Fabric network, it enables peer and orderer node health and
metric capabilities. The port to serve health check and metrics is normally called operation port, this port
is a different port than the Fabric node service GRPC port. Minifabric always sets the operation port to 7061
for peer and 7060 for orderer. Notice that the default service GRPC port for peer node is 7051, the default
port for orderer node is 7050, Minifabric adds 10 to the GRPC port for the operation port. When you choose to
expose node endpoints outside of your host (-e option of the minifab command), the operation port will also be mapped to a host port so that the operation port is accessible to tools running outside of the host. If you choose not to expose endpoints, then health and metrics will also be hidden from outside of the host and can only be accessed internally. To make things a
bit easier, the operation port for a node will always be 1000 higher than the node GRPC port. For example, if
a peer node is running on docker host which has the IP address 9.8.7.6 and its GRPC 7051 port is mapped to
7001, then the operation port will be 8001. As mentioned in another part of this documentation, you will have to make
sure that the block of these ports on your host are available. Using the above example, you can access health
and metrics at the following endpoints:

```
node:      9.8.7.6:8001
health:    9.8.7.6:9001/healthz
metrics:   9.8.7.6:9001/metrics
```

### Execution context
Minifab uses many settings throughout all the operations. These settings can be changed any time you run a minifab command and these settings will be saved in the vars/envsetting file. Each time a command is executed, that file will be loaded and settings specified in the command line will be written into that file. All the settings saved and specified in the command make the current execution context. They include the chaincode name, chaincode invocation parameters, chaincode version, chaincode language, channel name, Fabric release, endpoint exposure and block query number. 

All the default values are set by [envsettings](https://github.com/hyperledger-labs/minifabric/blob/main/envsettings). Each of the values gets updated if specified on a command line and saved back to `./vars/envsettings`. Users are strongly discouraged to manually change that file since it is basically a script. Changes to that file should only be made by the minifab command.

Because of the execution context, when you execute a command, you do not really have to specify all the parameters necessary if the context do not need to be changed. For example, if you just executed a chaincode invoke command, and you want to execute invoke again, then you do not need to specify the -n parameter because it is already in the current execution context. The same applies to every parameter listed in that file. You do not need to specify the parameter in a command unless you intend to use a new value in your command. Once you do, the new value becomes part of the current execution context. 

### Working with customised chaincode builders
Fabric (v>2.0) allows users to work with customised chaincode builders and runtime environments. This is particularly useful for users operating inside of restricted networks because chaincode builder images often need to access the external web for operations such as `npm install`. Once you have built a custom docker image, you can point minifab to it from `spec.yaml` e.g.
```
fabric:
  settings:
    peer:
      CORE_CHAINCODE_BUILDER: hyperledger/fabric-ccenv:my2.2
      CORE_CHAINCODE_NODE_RUNTIME: hyperledger/fabric-nodeenv:my2.2
```
where  `hyperledger/fabric-nodeenv:my2.2` is the name and tag for your custom image. Swap `NODE` for `GO` or `JAVA` for chaincodes written in those languages, respectively. Note that this sets the environment variable across all peer nodes (use multiple spec.yaml across multiple directories for more granular policy application).

### Update minifabric
Minifabric evolves very quickly. It is always a good idea to refresh your Minifabric every once in a while by simply running the following script
```
curl -o minifab -L https://tinyurl.com/twrt8zv && chmod +x minifab
docker pull hyperledgerlabs/minifab:latest
```

### See more available Minifabric commands
```
minifab
```

### For the people who has trouble to download images from docker hub
Minifabric uses Hyperledger official Docker images from Docker Hub. It will automatically pull these images when it needs them. For people with a slow internet connection, pulling images may be extremely slow or nearly impossible. To avoid breakages due to the image pulling issues, you may pull the following images from other docker repositories or use different means to pull these images such as, for example, writing your own script to pull images overnight. As long as these images exist on your machine, minifab will not pull them again. To help you with this, here is the list of images in case you want to pull them by some other means.

##### Fabric 2.0
```
hyperledgerlabs/minifab:latest
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
hyperledgerlabs/minifab:latest
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
If you would like to learn more, please watch the [series of 6 videos on how to develop Hyperledger Fabric using Minifabric](https://www.youtube.com/playlist?list=PL0MZ85B_96CExhq0YdHLPS5cmSBvSmwyO)

### Build minifabric locally
Minifabric when installed onto your system is really just a short script. After you run at least one minifab command, a docker image named hyperledgerlabs/minifab:latest will be automatically pulled down from Docker Hub. Throughout the life cycle of Minifabric, your system should only have this script and the Docker image. To remove Minifabric, you only need to remove the script and the Docker image. If you would like to build the Docker image yourself, please follow the steps below, the process applies to Linux, OS X and Windows:

```
git clone https://github.com/hyperledger-labs/minifabric.git
cd minifabric
docker build -t hyperledgerlabs/minifab:latest .
```

### Hook up Explorer to your Fabric network
If you would like to use a user interface to see your Fabric network, the transactions, and blocks, you can easily boot up Hyperledger Explorer by running the following
command:

```
minifab explorerup
```
The login userid and password to Explorer are `exploreradmin` and `exploreradminpw`

To shutdown Explorer, simply run the following command:

```
minifab explorerdown
```

Minifabric `cleanup` will also shutdown Hyperledger Explorer.

### Run your application quickly
If you already have your application developed, you can utilize Minifabric apprun command to quickly run your application. Place all your code in the vars/app/node or vars/app/go directory, then run the command `minifab apprun -l go` for application written in go, or run the command `minifab apprun -l node` for application written in node. Minifabric will stand up an environment to run your application. Minifabric comes with sample applications which invokes the samplecc chaincode. If you do not have an application, you can simply run the sample application to see how things work. Once you start the apprun command, Minifabric will place the necessary connection files in the app directory, then pull down dependencies and run your program. This feature is experimental, and application written in go or node are currently supported. To test your own application, replace the main.go or main.js file with your code, and possibly change the either package.json or mod.go to match your dependencies, then do command `minifab apprun`.

```
app
├── go.mod
├── go.sum
└── main.go
```

### Run Caliper test
Minifabric comes with a chaincode named samplecc written in go and a sample application which invokes samplecc methods. You can
use the following two commands to get Hyperledger Caliper running after you bring up your fabric network

```
minifab install,approve,commit,initialize -n samplecc -p ''
minifab caliperrun
```

After the commands finish, you can review the result in the `vars/report.html` file under the current working directory. It is
best to open this file in a browser.
If you would like to test your own chaincode, the easist way is to install, approve, commit and initialize your own chaincode just like any other chaincode using Minifabric commands. Then, use your own test code to replace the code in the vars/app/callback/app.js file, your own node js code must follow Caliper callback structure, otherwise caliperrun command will certainly fail. Once your chaincode correctly installed and your callback is in place, run `minifab caliperrun` command again to test your chaincode.
The caliperrun command will run the test for 60 seconds by default. If you wish to change the default settings that Minifabric sets to run the test, you can change vars/run/caliperbenchmarkconfig.yaml file after the first since this file gets created by Minifabric only when there is no such file. You can customize this file any way you want, make changes to any settings available in this file, and run the command again. All the changes you make will take effect the next time you run the command.

### Start up portainer web ui
While you are running your Fabric network, you can use Portainer web based management to see and interact with your running network.
To start up Portainer web user interface, simply run `minifab portainerup` command, to shut it down, run `minifab portainerdown` command

### Use Fabric operation console
If you like to use the Fabric operation console which was recently open sourced by IBM,you
can setup your fabric network by expose endpoints and then bring up the console. To do that
please follow these two steps:

```
   minifab up -e true
   minifab consoleup
```
The `consoleup` command will also create an asset file named assets.zip in vars/console
directory. This file contains admin wallets and various certificates and endpoints of
your entire fabric network. When you log in to the console, you may use this file to import
the information to the console to continue on.

To remove the console and all its related resources, please run the following command:

```
   minifab consoledown
```
