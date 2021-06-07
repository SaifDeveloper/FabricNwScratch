# FabricNwScratch

mkdir organizations/
mkdir organizations/cryptogen

write cryptoconfig.yaml for org1,org2,orderer

Point to binaries
export PATH=${PWD}/../bin:$PATH

cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output=organizations

cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output=organizations

cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output=organizations


Genesis Block

export FABRIC_CFG_PATH=${PWD}/configtx

configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block

. .env

docker-compose -f docker/docker-compose-test-net.yaml up -d


Channel Stuffs

configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/mychannel.tx -channelID mychannel

Anchor peer update

configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP

configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP

Writing new channel tx

Point FABRIC_CFG_PATH to core.yaml
export FABRIC_CFG_PATH=$PWD/../config/


export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt


export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
CORE_PEER_TLS_ENABLED=true CORE_PEER_LOCALMSPID="Org1MSP" CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp CORE_PEER_ADDRESS=localhost:7051

peer channel create -o localhost:7050 -c mychannel --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/mychannel.tx --outputBlock ./channel-artifacts/mychannel.block --tls --cafile $ORDERER_CA

peer channel create -o orderer.example.com:7050 -c mychannel --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/mychannel.tx --outputBlock ./channel-artifacts/mychannel.block --tls --cafile $ORDERER_CA

peer channel join -b ./channel-artifacts/mychannel.block


CORE_PEER_TLS_ENABLED=true CORE_PEER_LOCALMSPID="Org1MSP" CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp CORE_PEER_ADDRESS=localhost:7051 peer channel join -b ./channel-artifacts/mychannel.block

CORE_PEER_TLS_ENABLED=true CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp CORE_PEER_ADDRESS=localhost:9051 peer channel join -b ./channel-artifacts/mychannel.block

ORG1

export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

export CORE_PEER_LOCALMSPID="Org1MSP"

export PEER0_ORG1_CA=$PEER0_ORG1_CA
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt    
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

ORG2

export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

Anchor peer update

peer channel update -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls true --cafile $ORDERER_CA

peer channel update -o orderer.example.com:7050 --ordererTLSHostnameOverride orderer.example.com -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx --tls true --cafile $ORDERER_CA


CLEAR

docker-compose -f docker/docker-compose-test-net.yaml down --volume

docker volume prune
docker network prune

rm -rf channel-artifacts system-genesis-block organizations/ordererOrganizations organizations/peerOrganizations
