# MinIndy 

If you would like to learn Hyperledger Fabric or develop your smart contract, or
just want to get a feel of Hyperledger Fabric, Minifabric is the tool to
get you started. Minifabric can stand up a Fabric network on a small machine
like a VirtualBox VM but can also deploy Fabric networks across multiple production
grade servers. Minifabric has been tested on Linux, OS X, Windows 10 and supports
Fabric releases 1.4.4 or newer.

## Prerequisites
[docker](https://www.docker.com/) (18.03 or newer) environment

5 GB remaining Disk Storage available

##### If you are using Linux (Ubuntu, Fedora, CentOS), or OS X
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minindy -sL https://github.com/alanveloso/minindy/blob/main/minindy && chmod +x minindy
```

##### Make minifab available system wide

Move the minindy (Linux and OS X) script to a directory which is part of your execution PATH in your system or add the directory containing it to your PATH. This is to make the later operations a bit easier, you will be able to run the minifab command anywhere in your system without specifying the path to the minifab script.