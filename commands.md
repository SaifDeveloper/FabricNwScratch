#### Helpful commands

export PATH=${PWD}/../bin:$PATH

cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output=organizations

cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output=organizations

cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output=organizations


export FABRIC_CFG_PATH=${PWD}/configtx

configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block

configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/mychannel.tx -channelID mychannel


Anchor peer update

configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP

configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP

. .env

docker-compose -f docker/docker-compose-test-net.yaml up -d


Login into CLI

docker exec -it cliorg1 bash

export FABRIC_CFG_PATH=$PWD/../config/

peer channel create -o orderer.example.com:7050 -c mychannel --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/mychannel.tx --outputBlock ./channel-artifacts/mychannel.block --tls --cafile $ORDERER_CA

peer channel join -b ./channel-artifacts/mychannel.block

peer channel list

Anchor peer update

peer channel update -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls true --cafile $ORDERER_CA

peer channel update -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx --tls true --cafile $ORDERER_CA