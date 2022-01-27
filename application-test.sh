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