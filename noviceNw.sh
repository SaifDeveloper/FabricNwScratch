#!/bin/bash

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false

. scripts/utils.sh

export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

infoln "Generating Crypto"

cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output=organizations

cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output=organizations

cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output=organizations

infoln "Channel Artifacts"

mkdir channel-artifacts

configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block

configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/mychannel.tx -channelID mychannel


infoln "Anchor peer update"

configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP

configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP


. .env

infoln "Bring up the network"

docker-compose -f docker/docker-compose-test-net.yaml up -d

infoln "CLI Org1 - create channel"

docker exec cliorg1 peer channel create -o orderer.example.com:7050 -c mychannel --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/mychannel.tx --outputBlock ./channel-artifacts/mychannel.block --tls --cafile $ORDERER_CA

infoln "CLI Org1 - Join channel"

docker exec cliorg1 peer channel join -b ./channel-artifacts/mychannel.block

infoln "CLI Org1 - List channel"

docker exec cliorg1 peer channel list

infoln "CLI Org2 - Join channel"

docker exec cliorg2 peer channel join -b ./channel-artifacts/mychannel.block

infoln "CLI Org1 - List channel"

docker exec cliorg2 peer channel list

infoln "Anchor peer update"

docker exec cliorg1 peer channel update -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls true --cafile $ORDERER_CA

docker exec cliorg2 peer channel update -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx --tls true --cafile $ORDERER_CA

infoln "Done"