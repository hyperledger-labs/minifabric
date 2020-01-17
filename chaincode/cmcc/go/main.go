/*
Copyright 2009-2019 SAP SE or an SAP affiliate company. All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"github.com/golang/protobuf/proto"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/common"
	"github.com/hyperledger/fabric/protos/msp"
	pb "github.com/hyperledger/fabric/protos/peer"
	"math/rand"
	"time"
)

// ManagementChaincode serves functionalities to communicate channel updates and signatures between different channel members.
type ManagementChaincode struct {
}

// Proposal gathers all information of a proposed update, including all added signatures.
type Proposal struct {
	// Description describes the proposal.
	Description string `json:"description,omitempty"`

	// Creator contains the msp ID of the proposal creator.
	Creator string `json:"creator"`

	// ConfigUpdate contains the base64 string representation of the common.ConfigUpdate.
	ConfigUpdate string `json:"config_update"`

	// Signatures contains a map of signatures: mspID -> base64 string representation of common.ConfigSignature
	Signatures map[string]string `json:"signatures,omitempty"`
}

const (
	NewProposalEvent    = "newProposalEvent"
	DeleteProposalEvent = "deleteProposalEvent"
	NewSignatureEvent   = "newSignatureEvent"
)

// Init is called during Instantiate transaction after the chaincode container
// has been established for the first time, allowing the chaincode to
// initialize its internal data
func (mcc *ManagementChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

func main() {
	rand.Seed(time.Now().UTC().UnixNano())
	err := shim.Start(new(ManagementChaincode))
	if err != nil {
		fmt.Printf("Error starting management chaincode: %s", err)
	}
}

// Invoke is called to update or query the ledger in a proposal transaction.
// Updated state variables are not committed to the ledger until the
// transaction is committed.
func (mcc *ManagementChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	switch function {
	case "proposeUpdate":
		return mcc.proposeUpdate(stub, args)
	case "addSignature":
		return mcc.addSignature(stub, args)
	case "getProposals":
		return mcc.getProposals(stub, args)
	case "getProposal":
		return mcc.getProposal(stub, args)
	case "deleteProposal":
		return mcc.deleteProposal(stub, args)
	default:
		return shim.Error("Invalid invoke function name. Expecting \"proposeUpdate\" \"addSignature\" \"getProposals\" \"getProposal\" \"deleteProposal\".")
	}
}

// proposeUpdate creates a new proposal containing the given update and a description.
//
// Arguments:
//   0: proposalID  - the ID of the new proposal
//   1: update      - base64 encoded proto/common.ConfigUpdate
//   2: description - a short of the update
//
// Returns:
//   the ID of the created proposal
//
// Events:
//   name: newProposalEvent(<proposalID>)
//   payload: ID of the proposal
//
func (mcc *ManagementChaincode) proposeUpdate(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 3 {
		return shim.Error("incorrect number of arguments - expecting 3: proposalID, configUpdate, description")
	}

	proposalID := args[0]
	configUpdate := args[1]
	description := args[2]

	// check if the configUpdate is in the correct format: base64 encoded proto/common.ConfigUpdate
	update, err := base64.StdEncoding.DecodeString(configUpdate)
	if err != nil {
		return shim.Error(fmt.Sprintf("error happened decoding the configUpdate base64 string: %v", err))
	}
	if err := proto.Unmarshal(update, &common.ConfigUpdate{}); err != nil {
		return shim.Error(fmt.Sprintf("error happened decoding common.ConfigUpdate: %v", err))
	}

	if _, err := getProposal(stub, proposalID); err != ErrProposalNotFound {
		return shim.Error("ProposalID already in use.")
	}

	// create and store the proposal
	creator, err := stub.GetCreator()
	if err != nil {
		return shim.Error("error happened reading the transaction creator: " + err.Error())
	}
	mspID, err := getMSPID(creator)
	if err != nil {
		return shim.Error(err.Error())
	}
	proposal := Proposal{
		ConfigUpdate: configUpdate,
		Description:  description,
		Creator:      mspID,
	}
	propsosalJSON, err := json.Marshal(proposal)
	if err != nil {
		return shim.Error("error happened marshalling the new proposal: " + err.Error())
	}
	if err := stub.PutState(string(proposalID), propsosalJSON); err != nil {
		return shim.Error("error happened persisting the new proposal on the ledger: " + err.Error())
	}
	if err = stub.SetEvent(fmt.Sprintf("%s(%s)", NewProposalEvent, proposalID), []byte(proposalID)); err != nil {
		return shim.Error("error happened emitting event: " + err.Error())
	}
	return shim.Success([]byte(fmt.Sprintf("{\"proposal_id\":\"%v\"}", proposalID)))
}

// addSignature adds (or updates) a signature of the calling organization to the proposal.
//
// Arguments:
//   0: proposalID - the ID of the proposal where the signature is added
//   1: signature  - base64 encoded proto/common.ConfigSignature
//
// Events:
//   name: newSignatureEvent(<proposalID>)
//   payload: ID of the proposal
//
func (mcc *ManagementChaincode) addSignature(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 2 {
		return shim.Error("incorrect number of arguments - expecting 2: proposalID, signature")
	}
	proposalID := args[0]
	signature := args[1]

	// check if the signature is in the correct format: base64 encoded proto/common.ConfigSignature
	sig, err := base64.StdEncoding.DecodeString(signature)
	if err != nil {
		return shim.Error(fmt.Sprintf("error happened decoding the signature base64 string: %v", err))
	}
	if err := proto.Unmarshal(sig, &common.ConfigSignature{}); err != nil {
		return shim.Error(fmt.Sprintf("error happened decoding common.ConfigSignature: %v", err))
	}

	creator, err := stub.GetCreator()
	if err != nil {
		return shim.Error("error happened reading the transaction creator: " + err.Error())
	}
	mspID, err := getMSPID(creator)
	if err != nil {
		return shim.Error(err.Error())
	}

	// fetch and update the state of the proposal
	proposal, err := getProposal(stub, proposalID)
	if err != nil {
		return shim.Error(err.Error())
	}
	if proposal.Signatures == nil {
		proposal.Signatures = make(map[string]string)
	}
	proposal.Signatures[mspID] = signature

	// store the updated proposal
	proposalJSONUpdated, err := json.Marshal(proposal)
	if err != nil {
		return shim.Error("error happened marshalling the updated proposal: " + err.Error())
	}
	if err := stub.PutState(proposalID, proposalJSONUpdated); err != nil {
		return shim.Error("error happened persisting the updated proposal on the ledger: " + err.Error())
	}
	if err = stub.SetEvent(fmt.Sprintf("%s(%s)", NewSignatureEvent, proposalID), []byte(proposalID)); err != nil {
		return shim.Error("error happened emitting event: " + err.Error())
	}
	return shim.Success(nil)
}

// deleteProposal deletes the proposal with the given ID from the state.
// This can only be called by the proposal creator.
//
// Arguments:
//   0: proposalID - the ID of the proposal where the signature is added
//
// Events:
//   name: deleteProposalEvent(<proposalID>)
//   payload: ID of the proposal
//
func (mcc *ManagementChaincode) deleteProposal(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("incorrect number of arguments - expecting 1: proposalID")
	}
	proposalID := args[0]

	// fetch proposal
	proposal, err := getProposal(stub, proposalID)
	if err != nil {
		return shim.Error(err.Error())
	}

	creator, err := stub.GetCreator()
	if err != nil {
		return shim.Error("error happened reading the transaction creator: " + err.Error())
	}
	mspID, err := getMSPID(creator)
	if err != nil {
		return shim.Error(err.Error())
	}

	// check if calling organization is proposal creator
	if proposal.Creator != mspID {
		return shim.Error(fmt.Sprintf("forbidden. only the proposal creator (%s) can delete the proposal", proposal.Creator))
	}

	// delete the proposal
	if err := stub.DelState(proposalID); err != nil {
		return shim.Error(fmt.Sprintf("error happened deleting the state: %v", err))
	}
	if err = stub.SetEvent(fmt.Sprintf("%s(%s)", DeleteProposalEvent, proposalID), []byte(proposalID)); err != nil {
		return shim.Error("error happened emitting event: " + err.Error())
	}
	return shim.Success(nil)
}

// getProposals returns all proposals.
//
// Arguments: none
//
// Returns:
//   a map from proposalID to proposal
//
func (mcc *ManagementChaincode) getProposals(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 0 {
		return shim.Error("incorrect number of arguments - expecting 0")
	}
	proposals := make(map[string]*Proposal)
	proposalIterator, err := stub.GetStateByRange("", "")
	if err != nil {
		return shim.Error("error happened reading keys from ledger: " + err.Error())
	}
	defer proposalIterator.Close()

	for proposalIterator.HasNext() {
		proposalJSON, err := proposalIterator.Next()
		if err != nil {
			return shim.Error("error happened iterating over available proposals: " + err.Error())
		}
		proposal := &Proposal{}
		if err = json.Unmarshal(proposalJSON.Value, proposal); err != nil {
			return shim.Error("error happened unmarshalling a proposal JSON representation to struct: " + err.Error())
		}
		proposals[proposalJSON.Key] = proposal
	}

	proposalsJSON, err := json.Marshal(proposals)
	if err != nil {
		return shim.Error("error happened marshalling the update proposals: " + err.Error())
	}
	return shim.Success(proposalsJSON)
}

// getProposal returns the proposal with the given ID.
//
// Arguments:
//   0: proposalID - the ID of a proposal
//
// Returns:
//   the proposal with the given ID
//
func (mcc *ManagementChaincode) getProposal(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("incorrect number of arguments - expecting 1: proposalID")
	}
	proposalID := args[0]
	proposalJSON, err := stub.GetState(proposalID)
	if err != nil {
		return shim.Error(fmt.Sprintf("error happened reading proposal with id (%v): %v", proposalID, err))
	}
	if len(proposalJSON) == 0 {
		return shim.Error(fmt.Sprintf("proposal with id (%s) not found", proposalID))
	}
	return shim.Success(proposalJSON)
}

func getMSPID(creator []byte) (string, error) {
	identity := &msp.SerializedIdentity{}
	if err := proto.Unmarshal(creator, identity); err != nil {
		return "", fmt.Errorf("error happened unmarshalling the creator: %v", err)
	}
	return identity.Mspid, nil
}

// ErrProposalNotFound is returned when the requested object is not found.
var ErrProposalNotFound = fmt.Errorf("Proposal not found.")

// getProposal fetches and decodes the proposal with the given id from the state or returns an error.
func getProposal(stub shim.ChaincodeStubInterface, id string) (*Proposal, error) {
	proposalJSON, err := stub.GetState(id)
	if err != nil {
		return nil, fmt.Errorf("error happened reading proposal with id (%s): %v", id, err)
	}
	if len(proposalJSON) == 0 {
		return nil, ErrProposalNotFound
	}
	proposal := &Proposal{}
	if err := json.Unmarshal(proposalJSON, proposal); err != nil {
		return nil, fmt.Errorf("error happened unmarshalling the proposal JSON representation to struct: %v", err)
	}
	return proposal, nil
}
