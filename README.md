# Minifabric
This tool helps Fabric users working with fabric network. It currently provides the following functions:

1. Deploy a fabric network based on this [spec](spec.yaml) file
2. Tear down the deployed fabric network
3. Create new channels
4. Join peers to the new channels
5. Install chaincode
6. Instantiate chaincode

# Prerequsites
This tool requires docker CE 18.03 or newer.

# Get the script and make it executable
```
curl -o minifab -L https://tinyurl.com/twrt8zv && chmod +x minifab
```

You can also move script `minifab` into a directory which is part
of your $PATH such as ~/.local/bin to save time

# To stand up a fabric network:
```
minifab up
```

When it finishes, you should have a fabric network running on your machine

# To see other available fabric operations
```
minifab
```

# To tear down the fabric network:
```
minifab down
```

# To setup a network using a different spec
Simply download this [spec](spec.yaml) and make changes to what you like, then run the following
command in a directory where your new spec.yaml file is:

```
minifab up
```
