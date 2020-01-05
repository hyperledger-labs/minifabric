# Minifabric
This project helps Fabric users to deploy a simple fabric network on a single machine

# Prerequsites
This tool requires docker CE 18.03 or newer.

# Get the script and make it executable
```
curl -o minifab -L https://tinyurl.com/twrt8zv && chmod +x minifab
```

You can also move script `minifab` into a directory which is part
of your $PATH such as ~/.local/bin to save time

# To stand up a fabric network:
`
minifab up
`

When it finishes, you should have a fabric network running on your machine

# To see other available fabric operations
`
minifab
`

# To tear down the fabric network:
`
minifab down
`
