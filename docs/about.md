---
layout: page
title: About
nav_order: 2
permalink: /about/
---

## Introduction

The goal of this project is to build **[Hyperledger Fabric](https://hyperledger-fabric.readthedocs.io/en/release-2.2/)** based book management system for library, called `asset-transfer-library` and thus getting familiar to the concept of chaincode and application. All changes are made to `~/fabric-samples/asset-transfer-basic` to build a library system. Let’s take an overview how it works.

## Prerequisite

Follow all the steps in the [Hyperledger Fabric - Getting Started](https://hyperledger-fabric.readthedocs.io/en/release-2.2/getting_started.html) before executing any code or script in this repository. Once cloning the `fabric-samples` repository is finished, the procedure for bringing up the test network and installing chaincode is automized in `library-test.sh`.

```bash
#!/bin/bash
cd ~/fabric-samples/test-network
export PATH=$PATH:/usr/local/go/bin
./network.sh down
./network.sh up createChannel

# Install Chaincode
./network.sh deployCC -ccn basic -ccp ../asset-transfer-library/chaincode-go -ccl go

# Add binaries
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

# Environment variables for Org1
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

## Desigining a World State

World state for book management system is defined in `smartcontract.go`. 

```go
type Asset struct {
	ID             	string		`json:"ID"`
	Title          	string		`json:"Title"`
	Borrower       	string	`json:"Borrower"`
	Borrowed_Books 	int			`json:"Borrowed_Books"`
	Available_Books	int			`json:"Avaliable_Books"`
}
```

You can think of ID similar to ISBN, an unique number for a book. ID works as a key to find a specific book in this system. There can be multiple copies for a single book, so `Avaliable_Books` and `Borrowed_Books` are introduced to handle them. `Avaliable_Books` tells how many number of copies library currently have, while `Borrowed_Books` tells how many copies are borrowed at the point. 

Actually, current schema isn’t perfect and there are many rooms for improvements. Here, `Borrower` is defined as a string, not a list of strings. In this way, we can only keep track of borrowers in comma-separated string format, for example like `Tom, Harry, Jerry`. Also, for each copy of the book, borrowed date and expected return date is missing. Current schema can only work on very simple situation, where all borrowers are guaranteed to return the book on-time.

Note that since there is a change to the world state, functions that uses `Asset` also have to be changed.

## Writing Chaincode in Go

Writing chaincode is a tough job, as it is hard to catch errors before installing chaincode to peers and actually running it. Because of this, I tried to maintain chaincode as simple as possible, and implement the complex jobs in javascript application and python api. Here are some functions in `smartcontract.go`.

```go
// ReadAsset returns the asset stored in the world state with given id.
func (s *SmartContract) ReadAsset(ctx contractapi.TransactionContextInterface, id string) (*Asset, error) {
	assetJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if assetJSON == nil {
		return nil, fmt.Errorf("the asset %s does not exist", id)
	}

	var asset Asset
	err = json.Unmarshal(assetJSON, &asset)
	if err != nil {
		return nil, err
	}

	return &asset, nil
}

// UpdateAsset updates an existing asset in the world state with provided parameters.
func (s *SmartContract) UpdateAsset(ctx contractapi.TransactionContextInterface, id string, title string, borrower string, borrowed_books int, avaliable_books int) error {
	exists, err := s.AssetExists(ctx, id)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the asset %s does not exist", id)
	}

	// overwriting original asset with new asset
	asset := Asset{
		ID:             	id,
		Title:          	title,
		Borrower:       	borrower,
		Borrowed_Books:     borrowed_books,
		Available_Books: 	avaliable_books,
	}

	assetJSON, err := json.Marshal(asset)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, assetJSON)
}
```

I wrote a simple shell script for chaincode testing in `chaincode-test.sh`.

```bash
#!/bin/bash
cd ~/fabric-samples/test-network

# Testing the Chaincode
# Initialize the ledger
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'

# GetAllAssets
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'

# ReadAsset (asset5) -> Does not exist
peer chaincode query -C mychannel -n basic -c '{"function":"ReadAsset","Args":["asset5"]}'

# CreateAsset (asset5)
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"CreateAsset","Args":["asset5","test", "test", "1", "1"]}'

# ReadAsset (asset5) -> {"ID":"asset5","Title":"test","Borrower":"test","Borrowed_Books":1,"Avaliable_Books":1}
peer chaincode query -C mychannel -n basic -c '{"function":"ReadAsset","Args":["asset5"]}'
```

## Writing Application in Javascript

There were not many things to touch in `app.js`. Please refer to the detailed explanation in [Hyperledger Fabric - Writing Your First Application](https://hyperledger-fabric.readthedocs.io/en/release-2.2/write_first_app.html). `application-test.sh` refreshes wallet and executes `app.js` to test whether `smartcontract.go` is working well or not.

```bash
#!/bin/bash
cd ~/fabric-samples/test-network
./network.sh down
./network.sh up createChannel -c mychannel -ca
./network.sh deployCC -ccn basic -ccp ../asset-transfer-library/chaincode-go -ccl go
cd ~/fabric-samples/asset-transfer-library/application-javascript
cd wallet
rm -rf *.id
cd ..
node app.js
```

## Making Python API (Currently Working on it)

Using a module called `Naked`, python can execute `.js` files. I found out that some modularization in javascript application was needed to accomplish functioning python API. I managed to design the structure in this way.

- `enrollAdmin.js`
- `submitTransaction.js`
- `refreshWallet.sh`