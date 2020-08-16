### Running minifabric on Fedora server

Since Fedora by default has firewall enabled, without open up the masquerade, docker containers can not
communicate with each other. This doc outline necessary steps to help Fedora users to use minifabric.

Make sure that your Fedora system has docker 18.03 or newer installed
Run the following two commands to enable masquerade.

        sudo firewall-cmd --add-masquerade --permanent
        sudo firewall-cmd --reload

If you also consider expose your fabric node outside of the docker network, you will need to open up the ports that fabric node will map to:

        sudo firewall-cmd --add-port=7000-7009/tcp --permanent
        sudo firewall-cmd --reload
        
Notice that the above example opens up all the ports between 7000 and 7009, the default minifabric network spec file has 9 nodes. If your own spec file
has more or less nodes, then your range will need to be expanded or reduced accordingly.

Fedora version 31 and newer has switched to use cgroups v2 with which docker no longer works, to switch back to cgroups v1, you will have to do the following:

        sudo dnf install grubby
        sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
        
The above changes require system reboot.

Follow the normal linux instructions to download and run minifabric
