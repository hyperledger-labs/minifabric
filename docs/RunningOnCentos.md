# Running minifabric on Centos

Since Centos by default has firewall enabled, without open up the masquerade, docker containers
can not really function well, this doc outline necessary steps to help centos users to
use minifabric.

## Simply disable the firewall altogether
This will be the easiest solution, but doing this, you basically disabled the firewall.

Run the following commands
```
systemctl stop firewalld
systemctl disable firewalld
```

## Open up specific ports for peer, orderer nodes
Make sure that your system has docker 18.03 or newer installed, then run the following two commands to enable masquerade
```
    sudo firewall-cmd --add-masquerade --permanent
    sudo firewall-cmd --reload
```
If you also consider expose your fabric node outside of the docker network so that apps not running on your docker network
can also access these nodes, then you will need to open up the ports that fabric node will map to:
```
    sudo firewall-cmd --add-port=7000-7009/tcp --permanent
    sudo firewall-cmd --reload
```
Notice that the above example opens up all the ports between 7000 and 7009, which maps to the default minifabric network
spec file which has 9 nodes. If your own network spec has more or less nodes, then your range will need to be expanded or reduced accordingly.

Follow the normal linux instructions to download and run minifabric
