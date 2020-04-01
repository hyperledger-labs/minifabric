# Install the chaincode
minifab install -n privatemarbles -r true

# Modify the vars/privatemarbles_collection_config.json with the following content

```
[
 {
    "name": "collectionMarbles",
    "policy": "OR( 'org0examplecom.member', 'org1examplecom.member' )",
    "requiredPeerCount": 0,
    "maxPeerCount": 3,
    "blockToLive":1000000,
    "memberOnlyRead": true
 },
 {
    "name": "collectionMarblePrivateDetails",
    "policy": "OR( 'org0examplecom.member' )",
    "requiredPeerCount": 0,
    "maxPeerCount": 3,
    "blockToLive":3,
    "memberOnlyRead": true
 }
]
```
# Approve,commit,initialize the chaincode
    minifab approve,commit,initialize -p ''

# To init marble
    MARBLE=$( echo '{"name":"marble1","color":"blue","size":35,"owner":"tom","price":99}' | base64 | tr -d \\n )
    minifab invoke -p '"initMarble"' -t '{"marble":"'$MARBLE'"}'

    MARBLE=$( echo '{"name":"marble2","color":"red","size":50,"owner":"tom","price":102}' | base64 | tr -d \\n )
    minifab invoke -p '"initMarble"' -t '{"marble":"'$MARBLE'"}'

    MARBLE=$( echo '{"name":"marble3","color":"blue","size":70,"owner":"tom","price":103}' | base64 | tr -d \\n )
    minifab invoke -p '"initMarble"' -t '{"marble":"'$MARBLE'"}'

# To transfer marble
    MARBLE_OWNER=$( echo '{"name":"marble2","owner":"jerry"}' | base64 | tr -d \\n )
    minifab invoke -p '"transferMarble"' -t '{"marble_owner":"'$MARBLE_OWNER'"}'

# To query marble
    minifab query -p '"readMarble","marble1"' -t ''
    minifab query -p '"readMarblePrivateDetails","marble1"' -t ''
    minifab query -p '"getMarblesByRange","marble1","marble4"' -t ''

# To delete marble
    MARBLE_ID=$( echo '{"name":"marble1"}' | base64 | tr -d \\n )
    minifab invoke -p '"delete"' -t '{"marble_delete":"'$MARBLE_ID'"}'
