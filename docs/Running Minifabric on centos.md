# Running minifabric on Centos
Since centos by default has firewall enabled, without open up the masquerade, docker containers
can not really function well, this doc outline couple necessary steps to help centos users to
use minifabric.

1. Make sure that your Centos system has docker 18.03 or newer installed
2. Run the following two commands to enable masquerade
```
        firewall-cmd --zone=public --add-masquerade --permanent
        firewall-cmd --reload
```
3. Follow the normal linux instructions to download and run minifabric
