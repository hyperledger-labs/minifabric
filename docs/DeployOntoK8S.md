# Use Minifabric deploy Hyperledger Fabric onto Kubernetes

To deploy a Hyperledger Fabric network onto Kubernetes using Minifabric
is no difference than deploy Fabric onto a local Docker environment. The
only requirement is to have a working Kubernetes cluster and a running
Nginx Ingress controller.

Following the following steps to deploy Fabric onto Kubernetes:

### 1. Get Minifabric (Same process as described in the main README.md file)

##### If you are using Linux (Ubuntu, Fedora, CentOS), or OS X
```
mkdir -p ~/mywork && cd ~/mywork && curl -o minifab -sL https://tinyurl.com/yxa2q6yr && chmod +x minifab
```

##### If you are using Windows 10
```
mkdir %userprofile%\mywork & cd %userprofile%\mywork & curl -o minifab.cmd -sL https://tinyurl.com/y3gupzby
```

##### Make minifab available system wide

Move the minifab (Linux and OS X) or minifab.cmd (Windows) script to a directory which is part of your execution PATH in your system or add the directory containing it to your PATH. This is to make the later operations a bit easier, you will be able to run the minifab command anywhere in your system without specifying the path to the minifab script.

### 2. Docker environment where you run Minifabric

Minifabric is itself containerized. When it is working, it uses docker. If you do not
have Docker running on the machine you plan to run Minifabric, you should install docker
18.01 or newer. Without Docker, Minifabric will not work.

### 3. Prepare your kube config file

Minifabric depends on the kube config file to make connections to a running Kubernetes
cluster. You should have a kube config file ready as Minifabric vars/kubeconfig/config.
The file should have a read permission by root user. Getting your kube config file is
cloud dependent, please refer to each different cloud how to get the file. Typically
you would need to run cloud specific command such as `gcloud`, `ibmcloud`,`az`, `aws`
etc. Once you use different command to login, then you should run `kubectl get nodes`
to verify that you can indeed access the cluster. Minifabric itself does not use `kubectl`,
referencing it here is for you to verify that you can certainly login to the cluster.
`kubectl` command normally will produce a kube config file which is saved in `~/.kube/config`
you should be able to directly copy that file to Minifabric's `vars/kubeconfig/` directory
since that file contains access token.

### 4. (conditional) http proxy consideration

If http proxy exists between your operating machine and kubernetes,
you need follows this section. otherwise, skip to next section.

more specifically, when your case is:
- setup fabric from your office, onto cloud managed kubernetes cluster => follow this section
- setup fabric from your office, onto on-premise kubernetes cluster    => skip to next section.
- other cases                                                          => maybe skip to next section.


at current, it needs to set following envirormnent varibales in terminall shell.

on linux:
```bash
#
export https_proxy=http://yourID:yourPass@yourProxyhost:port/
# you can use no_proxy environment vairable as usuall.
export no_proxy=localhost,127.0.0.1/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.local,*.yourdomain.com

# for kubernetes operation via ansible
export K8S_AUTH_PROXY=http://yourProxyhost:port/
export K8S_AUTH_PROXY_HEADERS_PROXY_BASIC_AUTH=yourID:yourPass
```

on win10:
```bat
set https_proxy=http://yourID:yourPass@yourProxyhost:port/
set no_proxy=localhost,127.0.0.1/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.local,*.yourdomain.com
set K8S_AUTH_PROXY=http://yourProxyhost:port/
set K8S_AUTH_PROXY_HEADERS_PROXY_BASIC_AUTH=yourID:yourPass
REM you can set above variables as environment variables in win10 OS.
```

### 5. Prepare Nginx ingress controller

Minifabric uses kubernetes ingress services to expose Fabric node endpoints. Without
ingress to expose Fabric node endpoints, Fabric will be only available inside a kubernetes
cluster which normally is not very useful. To deploy Nginx Ingress controller, one simply
need to run the following command.

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/cloud/deploy.yaml
```

Please refer the document here[https://kubernetes.github.io/ingress-nginx/deploy/] for more information
on Nginx ingress controller

Once it is deployed and running, you should get a public IP address which is needed to
config your Minifabric spec.yaml file.

### 6. Prepare your Minifabric spec file

Create a yaml file named `spec.yaml` in Minifabric's working directory. The following is an example

```
fabric:
  cas:
  - "ca1.org0.example.com"
  - "ca1.org1.example.com"
  peers: 
  - "peer1.org0.example.com"
  - "peer2.org0.example.com"
  - "peer1.org1.example.com"
  - "peer2.org1.example.com"
  orderers:
  - "orderer1.example.com"
  - "orderer2.example.com"
  - "orderer3.example.com"
  settings:
    ca:
      FABRIC_LOGGING_SPEC: DEBUG
    peer:
      FABRIC_LOGGING_SPEC: DEBUG
    orderer:
      FABRIC_LOGGING_SPEC: DEBUG
  ### use go proxy when default go proxy is restricted in some of the regions.
  ### the default goproxy
  # goproxy: "https://proxy.golang.org,direct"
  ### the goproxy in China area
  # goproxy: "https://goproxy.cn,direct"
  ### set the endpoint address to override the automatically detected IP address
  endpoint_address: <The public IP address from your ingress controller>
  ### set the docker network name to override the automatically generated name.
  netname: "mysite0"
  ### set the extra optins for docker run command
  # container_options: "--restart=always --log-opt max-size=10m --log-opt max-file=3"
```

Notice the `endpoint_address` field, which was optional when deploy in docker env, but
it is now mandatory for Kubernetes deployment. Without configuring this entry, when
Minifabric detectes the presence of the `vars/kubeconfig/config` file, it will fail
the process. In this `spec.yaml` file, you can customize the node just like you do
normally with Docker environment deployment.

### 7. (optional) Assign labels to nodes for controlling pod and node binding.

first, check the node and labels in your k8s.
```
kubectl get node --show-labels
NAME        STATUS   ROLES    AGE    VERSION   LABELS
node1       Ready    <none>   3h12m   v1.19.6  ...
node2       Ready    <none>   3h12m   v1.19.6  ...
```

assign labels  to node for controlling pod and node binding.
```
# this is a sample, play and decide bindings by yourself

# add label to node
#      all pods in org0 => node1
kubectl label node node1 dock.hlf-dn/org0.example.com=ok
#      all pods in org1 => node2
kubectl label node node2 dock.hlf-dn/org1.example.com=ok
#      all ordererer  => node2, excepts orderer1 => node1
kubectl label node node2 dock.hlf-type/orderer=ok
kubectl label node node1 dock.hlf-fqdn/orderer1.example.com=ok
:

# delete label from node
kubectl label node node1 dock.hlf-dn/org0.example.com-
kubectl label node node2 dock.hlf-dn/org1.example.com-
kubectl label node node2 dock.hlf-type/orderer-
kubectl label node node1 dock.hlf-fqdn/orderer1.example.com-
:
```

As you see the above, three types of label involved to control the pod's destination node.

* Type A (strongest;  dock.hlf-fqdn/*)
   - you can fully control, one by one.
   - the word following 'dock.hlf-fqdn/' is up to your spec.yaml.
* Type B (second;     dock.hlf-type/*)
   - you can control type by type.
   - defined labels are followings:
       - dock.hlf-type/peer:     all pods listed in 'peers:' of spec.yaml
       - dock.hlf-type/orderer:  all pods listed in 'orderer:' of spec.yaml
       - dock.hlf-type/ca:       all pods listed in 'cas:' of spec.yaml
       - dock.hlf-type/couchdb:  all backend pods for peers only if 'minifab ... -s couchdb' is supecified.
* Type C (3rd;        dock.hlf-dn/*)
   - you can control domain by domain
   - the word following 'dock.hlf-dn/' is up to your spec.yaml.

* note: node labeling for couchdb needs a little care as following example:
   - dock.hlf-fqdn/peer1.org0.example.com.couchdb=ok   ('.couchdb' appended at the end of the frontend peer's fqdn).
   - dock.hlf-dn/org0.example.com=ok controls couchdb as well as peer and ca.

* You can assign multiple labels to a node(in mixing also allowed).
* after pods deployment, you can check binding results by ```kubectl get pod -A -o wide```
* this feature works ONLY IF you assigned labels BEFORE deploying Fabric network.

* NOTE: k8s deploys a pod by original manner as before, in following cases:
   - if corresponding label is not assigned in any nodes.
   - if destination node reached to the max-pods-per-node limitation


### 8. Deploy Fabric network onto your Kubernetes cluster

Once all the above steps are done, you can run the `minifab up` command to get your
Fabric network running in the Kubernetes cluster.

```
   minifab up -e true
```

Notice the `-e` command line flag which is now also required for the same reason as
the `endpoint_address` configuration in `spec.yaml` file

### 9. Remove Fabric network from your Kubernetes cluster

To remove everything including the persistent storage created during the deployment,
you can simply run the good old `minifab cleanup` command:

```
   minifab cleanup
```

### 10. How about other operations?

Minifabric supports all operations in Kubernetes cluster just like it supports
all Fabric operations like in Docker env. If you like to join a channel, install
a chaincode etc, you do exactly the same. For example, to create a new channel, run
the following command:

```
   minifab create -c funchannel
```

To join peers defined in `spec.yaml` to current channel, run this command:

```
   minifab join
```

To install a chaincode to all the nodes defined in `spec.yaml` file, run this command

```
   minifab install -n mychaincode
```
Just to make sure that your chaincode source is in the `vars/chaincode/mychaincode`
directory.

Any other command which has not been discussed above works exactly same way as in
Docker environment.
