---
layout: default
title: Home
nav_order: 1
permalink: /
---

# Asset Transfer Library
{: .fs-9 }

**Asset Transfer Library** is a Hyperledger Fabric based book management system for library. It is a collection of chaincode and application that works on `fabric-samples/test-network`. 
{: .fs-6 .fw-300 }

[View it on GitHub](https://github.com/scottsuk0306/asset-transfer-library){: .btn .fs-5 .mb-4 .mb-md-0 }

---

## Getting started

### Dependencies
asset-transfer-library is built on 
`fabric-samples` repository. Follow all the steps in the [Hyperledger Fabric - Getting Started](https://hyperledger-fabric.readthedocs.io/en/release-2.2/getting_started.html) before executing any code or script in this repository.

### Installation

1. Install the repository.
```bash
$ cd ~/fabric-samples
$ git clone https://github.com/scottsuk0306/asset-transfer-library
```
2. Bring up the test network.
```bash
$ cd ~/fabric-samples/asset-transfer-library
$ ./library-test.sh
```
3. Try out some bash scripts in `~/fabric-samples/asset-transfer-library`.
```bash
$ ./chaincode-test.sh
$ ./application-test.sh
```
4. _Optional:_ Modify the world state in design and functions in `chaincode-go/chaincode/smartcontract.go` based on your use.