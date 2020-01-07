# Minifabric
This tool helps Fabric users working with fabric network. It currently provides the following functions:

1. Deploy a fabric network based on this [spec](spec.yaml) file
2. Tear down the deployed fabric network
3. Create new channels
4. Join peers to the new channels
5. Install chaincode or your own chaincode
6. Instantiate chaincode

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

When it finishes, you should have a fabric network running on your machine.
You will also have an application channel named `mychannel` created, all
peers defined in the spec joined into that channel, and a chaincode named
`chaincode_example02` being installed and instantiated.

# See more available fabric operations
```
minifab
```

# Tear down the fabric network:
```
minifab down
```

# Setup a network using a different spec
Simply download this [spec](spec.yaml) and make changes to what you like, then run the following
command in a directory where your new spec.yaml file is:

```
minifab up
```

# To install your own chaincode
Create the following directory:
  
```
mkdir -p $(pwd)/vars/chaincode/<chaincodename>/go
```
where <chaincodename> should be the name you give to your chaincode

Place your code in that directory, then do the following
```
minifab install -n <chaincodename> -v 1.0
```
If your chaincode is written in node or java, your code should go to the following directories respectively
```
$(pwd)/vars/chaincode/<chaincodename>/node
$(pwd)/vars/chaincode/<chaincodename>/java
```

If you have no chaincode developed and run `minifab install` command, minifab will install the sample chaincode named chaincode_example02 which comes with minifab.
