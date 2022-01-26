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