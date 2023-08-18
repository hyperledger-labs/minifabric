# MinIndy 

If you would like to learn Hyperledger Indy, or just want to get a feel of Hyperledger Indy, MinIndy is the tool to get you started. MinIndy can stand up a Indy network on a small machine
like a VirtualBox VM but can also deploy Indy networks across multiple production
grade servers. MinIndy has been tested on Linux.

## Prerequisites
[docker](https://www.docker.com/) (18.03 or newer) environment

5 GB remaining Disk Storage available

##### If you are using Linux (Ubuntu, Fedora, CentOS), or OS X
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minindy -sL https://raw.githubusercontent.com/alanveloso/minindy/main/minindy && chmod +x minindy
```

##### Make minifab available system wide

Move the minindy (Linux and OS X) script to a directory which is part of your execution PATH in your system or add the directory containing it to your PATH. This is to make the later operations a bit easier, you will be able to run the minifab command anywhere in your system without specifying the path to the minifab script.