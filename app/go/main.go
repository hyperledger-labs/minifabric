package main

import (
	"fmt"
	"github.com/google/uuid"
	"github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
	"github.com/hyperledger/fabric-sdk-go/pkg/client/msp"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/errors/retry"
	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
	"github.com/hyperledger/fabric-sdk-go/pkg/gateway"
	rmsp "github.com/hyperledger/fabric-sdk-go/pkg/msp"
	"math/rand"
	"os"
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

func doEnroll() {
	//Load configuration from connection profile
	cnfg := config.FromFile("./connection.json")
	sdk, err := fabsdk.New(cnfg)
	if err != nil {
		fmt.Printf("Failed to create new SDK: %s", err)
		return
	}
	defer sdk.Close()

	// Try to get some configuration data from the connection profile
	sdkcfg, _ := sdk.Config()
	idcfg, _ := rmsp.ConfigFromBackend(sdkcfg)
	caconfig, ok := idcfg.CAConfig("ca1.org1.example.com")
	if !ok {
		fmt.Println("Could not get the caconfiguration.")
		return
	}
	fmt.Println(caconfig.Registrar.EnrollID)
	fmt.Println(caconfig.Registrar.EnrollSecret)

	ctxProvider := sdk.Context()
	mspClient, err := msp.New(ctxProvider)
	if err != nil {
		fmt.Printf("Failed to create new msp client: %s", err)
		return
	}

	// Now try to enroll the admin with its configured ID and password
	err = mspClient.Enroll(caconfig.Registrar.EnrollID, msp.WithSecret(caconfig.Registrar.EnrollSecret))
	if err != nil {
		fmt.Printf("Failed to enroll the admin: %s", err)
		return
	}
	fmt.Println("Enrollment is fine")

	// Try to query all identities
	fmt.Println(reflect.TypeOf(mspClient))
	ids, err := mspClient.GetAllIdentities()
	if err != nil {
		fmt.Printf("Failed to get all ids: %s", err)
		return
	}

	for _, id := range ids {
		fmt.Printf("an id %v", id.ID)
	}

	//Register a new user
	username := "user" + strconv.Itoa(rand.Intn(500000))
	userpw, err := mspClient.Register(&msp.RegistrationRequest{Name: username})
	if err != nil {
		fmt.Printf("Failed to get all ids: %s", err)
		return
	}
	fmt.Printf("The new user %v", userpw)

	//Enroll with returned password
	err = mspClient.Enroll(username, msp.WithSecret(userpw))
	if err != nil {
		fmt.Printf("Failed to enroll the admin: %s", err)
		return
	}
	fmt.Println("Enrollment is fine")
}

func useClientExecute(index int) {
	cnfg := config.FromFile("./connection.json")
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
		gateway.WithConfig(config.FromFile("./connection.json")),
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

/*
To run this app, make sure that one of the wallet files such as Admin.id from
vars/profiles/vscode/wallets directory is copied onto ./wallets directory,
then this example code will use the wallet file and connection file to make
connections to Fabric network
*/
func useWalletGateway() {
	wallet, err := gateway.NewFileSystemWallet("./wallets")
	if err != nil {
		fmt.Printf("Failed to create wallet: %s\n", err)
		os.Exit(1)
	}

	if !wallet.Exists("Admin") {
		fmt.Println("Failed to get Admin from wallet")
		os.Exit(1)
	}

	gw, err := gateway.Connect(
		gateway.WithConfig(config.FromFile("./connection.json")),
		gateway.WithIdentity(wallet, "Admin"),
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
	useWalletGateway()
}
