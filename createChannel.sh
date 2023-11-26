export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER1_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export PEER1_ORG2_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
export PEER1_ORG3_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org3.example.com/peers/peer1.org3.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

setGlobalsForPeer0Org1() {
  export CORE_PEER_LOCALMSPID="Org1MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
  export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Org1() {
  export CORE_PEER_LOCALMSPID="Org1MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG1_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
  export CORE_PEER_ADDRESS=localhost:7061
}

setGlobalsForPeer0Org2() {
  export CORE_PEER_LOCALMSPID="Org2MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
  export CORE_PEER_ADDRESS=localhost:9051
}

setGlobalsForPeer1Org2() {
  export CORE_PEER_LOCALMSPID="Org2MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG2_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
  export CORE_PEER_ADDRESS=localhost:9061
}

setGlobalsForPeer0Org3() {
  export CORE_PEER_LOCALMSPID="Org3MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
  export CORE_PEER_ADDRESS=localhost:11051
}

setGlobalsForPeer1Org3() {
  export CORE_PEER_LOCALMSPID="Org3MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG3_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
  export CORE_PEER_ADDRESS=localhost:11061
}

setGlobalsForIOTChannel() {
  export CHANNEL_NAME=iotchannel
}

setGlobalsForPeerChannel() {
  export CHANNEL_NAME=peerChannel
}

createIOTChannel() {
  setGlobalsForIOTChannel
  setGlobalsForPeer0Org1

  peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.example.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

createPeerChannel() {
  setGlobalsForPeerChannel
  setGlobalsForPeer0Org1

  peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.example.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

createChannel() {
  rm -rf ./channel-artifacts/*
  createIOTChannel
  createPeerChannel
}

removeOldCrypto() {
  rm -rf ./api-1.4/crypto/*
  rm -rf ./api-1.4/fabric-client-kv-org1/*
  rm -rf ./api-2.0/org1-wallet/*
  rm -rf ./api-2.0/org2-wallet/*
}

joinIOTChannel() {
  setGlobalsForIOTChannel

  setGlobalsForPeer0Org1
  peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

  setGlobalsForPeer1Org1
  peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

  setGlobalsForPeer0Org2
  peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

  setGlobalsForPeer1Org2
  peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

  setGlobalsForPeer0Org3
  peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

  setGlobalsForPeer1Org3
  peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
}

joinPeerChannel() {
  setGlobalsForPeerChannel

  setGlobalsForPeer0Org1
  peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

  setGlobalsForPeer0Org2
  peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

  setGlobalsForPeer0Org3
  peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
}

joinChannel() {
  joinIOTChannel
  joinPeerChannel
}

updateAnchorIOT() {
  setGlobalsForIOTChannel

  setGlobalsForPeer0Org1
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

  setGlobalsForPeer0Org2
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

  setGlobalsForPeer0Org3
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

updateAnchorPeers() {
  setGlobalsForPeerChannel

  setGlobalsForPeer0Org1
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

  setGlobalsForPeer0Org2
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

  setGlobalsForPeer0Org3
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

updateAnchor() {
  updateAnchorIOT
  updateAnchorPeers
}

removeOldCrypto

createChannel
joinChannel
updateAnchor