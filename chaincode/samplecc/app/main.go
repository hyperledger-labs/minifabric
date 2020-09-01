package main

import (
	"fmt"
	"github.com/google/uuid"
	"github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/errors/retry"
	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
	"github.com/hyperledger/fabric-sdk-go/pkg/gateway"
	"math/rand"
	"reflect"
	"strconv"
	"sync"
	"time"
)

const (
	ccID      = "samplecc"
	channelID = "mychannel"
	orgName   = "org1.example.com"
	orgAdmin  = "Admin"
)

func useClientExecute(index int) {
	cnfg := config.FromFile("./mychannel_connection_for_gosdk.json")
	fmt.Println(reflect.TypeOf(cnfg))
	sdk, err := fabsdk.New(cnfg)
	if err != nil {
		fmt.Printf("Failed to create new SDK: %s", err)
	}
	defer sdk.Close()
	clientChannelContext := sdk.ChannelContext(channelID, fabsdk.WithUser(orgAdmin), fabsdk.WithOrg(orgName))
	client, err := channel.New(clientChannelContext)
	if err != nil {
		fmt.Printf("Failed to create new channel client: %s", err)
	} else {
		fmt.Println(reflect.TypeOf(client))
	}

	start := time.Now()
	var defaultTxArgs = [][]byte{[]byte("put"), []byte("somekey"), []byte(strconv.Itoa(index))}

	_, err = client.Execute(channel.Request{ChaincodeID: ccID, Fcn: "invoke", Args: defaultTxArgs},
		channel.WithRetry(retry.DefaultChannelOpts))
	if err != nil {
		fmt.Printf("Failed to move funds: %v", err)
	}

	fmt.Println("The time took is ", time.Now().Sub(start))
}

func useGateway() {
	gw, err := gateway.Connect(
		gateway.WithConfig(config.FromFile("./mychannel_connection_for_gosdk.json")),
		gateway.WithUser("Admin"),
	)
	if err != nil {
		fmt.Printf("Failed to connect: %v", err)
	}

	if gw == nil {
		fmt.Println("Failed to create gateway")
	}

	network, err := gw.GetNetwork("mychannel")
	if err != nil {
		fmt.Printf("Failed to get network: %v", err)
	}

	var seededRand *rand.Rand = rand.New(rand.NewSource(time.Now().UnixNano()))
	contract := network.GetContract("samplecc")
	uuid.SetRand(nil)

	var wg sync.WaitGroup
	start := time.Now()
	for i := 1; i <= 10; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			seededRand.Intn(20)
			result, err := contract.SubmitTransaction("invoke", "put", uuid.New().String(),
				strconv.Itoa(seededRand.Intn(20)))
			if err != nil {
				fmt.Printf("Failed to commit transaction: %v", err)
			} else {
				fmt.Println("Commit is successful")
			}

			fmt.Println(reflect.TypeOf(result))
			fmt.Printf("The results is %v", result)
		}()
	}
	wg.Wait()
	fmt.Println("The time took is ", time.Now().Sub(start))
}

func main() {
	useGateway()
}
