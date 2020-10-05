# Add a new organization to the existing network

There are normally two different cases to add a new organization to a running fabric network.
Both cases are essentially the channel configuration update operations. If a new organization
goes into application channel, then the new organization wont be able to create new channels.
If a new organization goes into system channel, then the new organization will be able to
create new channels.

1. [New organization to application channel easy way](#new-organization-to-application-channel-easy-way)
2. [New organization to system channel](#new-organization-to-system-channel)
3. [New organization to application channel (Fast Way)](#new-organization-to-application-channel)

### New organization to application channel easy way

Find the new organization's JoinRequest json file and save it as `vars/NewOrgJoinRequest.json`.
If you are using minifabric `netup` command setting up the new org, that file will be create in the
working directory's `vars` directory. If you are using other means setting up new org, then you most
likely have to manually create the file.

Run the following command:

```
  minifab orgjoin
```

This command will retrieve the current channel configuration, then merge the new org's request,
eventually do channel sign off and channel update. Once it is done, you can do `minifab channelquery`
to verify that the new organization is part of the channel

### New organization to system channel
1. Use minifab channelquery command to get the system channel configuration
```
   minifab channelquery -c systemchannel
```
The above command should produce a file named vars/systemchannel_config.json file.

2. Find the new organization configuration, if you are using minifabric to stand up a new
organization, then you should already have the file in vars directory on the host where
minifabric was run, each organization should have a JoinRequest file. The names of these
files should follow a pattern like this:

```
   JoinRequest_<organization msp id>.json

   For example:
   JoinRequest_org50-example-com.json
```

Place the new organization configuration file in the working directory. In all the following
steps, we assume that the new organization configuration file is named JoinRequest_org50-example-com.json

3. Once you have the system channel configuration json file and new organization configuration
files ready, run the following command one long line to produce a new channel configuration file

```
  jq -s '.[0] * {"channel_group":{"groups":{"Consortiums":{"groups":{"SampleConsortium":{"groups":
  {(.[1].values.MSP.value.config.name): .[1]}}}}}}}' vars/systemchannel_config.json
  JoinRequest_org50-example-com.json |
  jq -s '.[0] * {"channel_group":{"groups":{"Consortiums":{"groups":{"SampleConsortium":{"version":
  (.[0].channel_group.groups.Consortiums.groups.SampleConsortium.version|tonumber + 1)|tostring }}}}}}' > updatedchannel.json
```

The above command assumes that the consortium is named `SampleConsortium`. When you setup fabric network using
minifabric, the system channel name is `systemchannel`, the consortium name is `SampleConsortium`. If your fabric
network was not setup by minifabric, your system channel name and consortium name can be different.
Since you are adding an element to the channel configuration json file, you will have to increase the version number
of the changing element, in this case, the element is channel_group.groups.Consortiums.groups.SampleConsortium.
Now use the updatedchannel.json to overwrite the vars/systemchannel_config.json

```
  sudo cp updatedchannel.json vars/systemchannel_config.json
```

5. Now simply run the following command to make the new organization a part of the application channel

```
   minifab channelsign,channelupdate -c systemchannel
```

If you have organizations spread out onto multiple hosts, you will need to run channelsign on the hosts
which make up majority of the channels or the required number of orgs by your channel endorsement policy.
The signed file will have to be passed from one org to the other so that all the endorsements are gathered
when channel update command runs.

### New organization to application channel

1. Use minifab channelquery command to get an existing channel configuration
```
   minifab channelquery -c mychannel
```
The above command should produce a file named vars/mychannel_config.json file.

2. Find the new organization configuration, if you are using minifabric to stand up a new
organization, then you should already have the file in vars directory on the host where
minifabric was run, each organization should have a JoinRequest file. The names of these
files should follow the pattern like this:

```
   JoinRequest_<organization msp id>.json

   For example:
   JoinRequest_org50-example-com.json
```

Place the new organization configuration file in the working directory. In all the following
steps, we assume that the new organization configuration file is named JoinRequest_org50-example-com.json

3. Once you have the channel configuration json file and new organization configuration
files ready, run the following command to produce a new new channel configuration file.

```
  jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {(.[1].values.MSP.value.config.name): .[1]}}}}}'
  vars/mychannel_config.json JoinRequest_org50-example-com.json |
  jq -s '.[0] * {"channel_group":{"groups":{"Application":{"version":
  (.[0].channel_group.groups.Application.version|tonumber + 1)|tostring }}}}' > updatedchannel.json
```

Since you are adding a json element to an element in the channel configuration file, you will have
to increase the version number of the changing element, in this case, the element is
channel_group.groups.Application. Verify that the new org is now part of the newchannel.json file
and also make sure that the version of the element has increased by 1. Now use the updatedchannel.json
to overwrite the vars/mychannel_config.json

```
  sudo cp updatedchannel.json vars/mychannel_config.json
```

4. Now simply run the following command to make the new organization a part of the application channel

```
   minifab channelsign,channelupdate
```

If you have organizations spread out onto multiple hosts, you will need to run channelsign on the hosts
which make up majority of the channels or the required number of orgs by your channel endorsement policy.
The signed file will have to be passed from one org to the other so that all the endorsements are gathered
when channel update command runs.
