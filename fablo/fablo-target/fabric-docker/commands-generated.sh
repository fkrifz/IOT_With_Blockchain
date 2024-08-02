#!/usr/bin/env bash

generateArtifacts() {
  printHeadline "Generating basic configs" "U1F913"

  printItalics "Generating crypto material for OrdererOrg" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-ordererorg.yaml" "peerOrganizations/orderer.ac.id" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for Org1" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-org1.yaml" "peerOrganizations/org1.ac.id" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating genesis block for group orderer" "U1F3E0"
  genesisBlockCreate "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config" "OrdererGenesis"

  # Create directory for chaincode packages to avoid permission errors on linux
  mkdir -p "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"
}

startNetwork() {
  printHeadline "Starting network" "U1F680"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose up -d)
  sleep 4
}

generateChannelsArtifacts() {
  printHeadline "Generating config for 'storage-channel'" "U1F913"
  createChannelTx "storage-channel" "$FABLO_NETWORK_ROOT/fabric-config" "StorageChannel" "$FABLO_NETWORK_ROOT/fabric-config/config"
}

installChannels() {
  printHeadline "Creating 'storage-channel' on Org1/peer0" "U1F63B"
  docker exec -i cli.org1.ac.id bash -c "source scripts/channel_fns.sh; createChannelAndJoin 'storage-channel' 'Org1MSP' 'peer0.org1.ac.id:7041' 'crypto/users/Admin@org1.ac.id/msp' 'orderer0.orderer.orderer.ac.id:7030';"

}

installChaincodes() {
  if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/storage-chaincode")" ]; then
    local version="1.0.0"
    printHeadline "Packaging chaincode 'storage-chaincode'" "U1F60E"
    chaincodeBuild "storage-chaincode" "node" "$CHAINCODES_BASE_DIR/./chaincodes/storage-chaincode" "16"
    chaincodePackage "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-chaincode" "$version" "node" printHeadline "Installing 'storage-chaincode' for Org1" "U1F60E"
    chaincodeInstall "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-chaincode" "$version" ""
    chaincodeApprove "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-channel" "storage-chaincode" "$version" "orderer0.orderer.orderer.ac.id:7030" "" "false" "" ""
    printItalics "Committing chaincode 'storage-chaincode' on channel 'storage-channel' as 'Org1'" "U1F618"
    chaincodeCommit "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-channel" "storage-chaincode" "$version" "orderer0.orderer.orderer.ac.id:7030" "" "false" "" "peer0.org1.ac.id:7041" "" ""
  else
    echo "Warning! Skipping chaincode 'storage-chaincode' installation. Chaincode directory is empty."
    echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/storage-chaincode'"
  fi

}

installChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "storage-chaincode" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/storage-chaincode")" ]; then
      printHeadline "Packaging chaincode 'storage-chaincode'" "U1F60E"
      chaincodeBuild "storage-chaincode" "node" "$CHAINCODES_BASE_DIR/./chaincodes/storage-chaincode" "16"
      chaincodePackage "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-chaincode" "$version" "node" printHeadline "Installing 'storage-chaincode' for Org1" "U1F60E"
      chaincodeInstall "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-chaincode" "$version" ""
      chaincodeApprove "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-channel" "storage-chaincode" "$version" "orderer0.orderer.orderer.ac.id:7030" "" "false" "" ""
      printItalics "Committing chaincode 'storage-chaincode' on channel 'storage-channel' as 'Org1'" "U1F618"
      chaincodeCommit "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-channel" "storage-chaincode" "$version" "orderer0.orderer.orderer.ac.id:7030" "" "false" "" "peer0.org1.ac.id:7041" "" ""

    else
      echo "Warning! Skipping chaincode 'storage-chaincode' install. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/storage-chaincode'"
    fi
  fi
}

runDevModeChaincode() {
  local chaincodeName=$1
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "storage-chaincode" ]; then
    local version="1.0.0"
    printHeadline "Approving 'storage-chaincode' for Org1 (dev mode)" "U1F60E"
    chaincodeApprove "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-channel" "storage-chaincode" "1.0.0" "orderer0.orderer.orderer.ac.id:7030" "" "false" "" ""
    printItalics "Committing chaincode 'storage-chaincode' on channel 'storage-channel' as 'Org1' (dev mode)" "U1F618"
    chaincodeCommit "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-channel" "storage-chaincode" "1.0.0" "orderer0.orderer.orderer.ac.id:7030" "" "false" "" "peer0.org1.ac.id:7041" "" ""

  fi
}

upgradeChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "storage-chaincode" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/storage-chaincode")" ]; then
      printHeadline "Packaging chaincode 'storage-chaincode'" "U1F60E"
      chaincodeBuild "storage-chaincode" "node" "$CHAINCODES_BASE_DIR/./chaincodes/storage-chaincode" "16"
      chaincodePackage "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-chaincode" "$version" "node" printHeadline "Installing 'storage-chaincode' for Org1" "U1F60E"
      chaincodeInstall "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-chaincode" "$version" ""
      chaincodeApprove "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-channel" "storage-chaincode" "$version" "orderer0.orderer.orderer.ac.id:7030" "" "false" "" ""
      printItalics "Committing chaincode 'storage-chaincode' on channel 'storage-channel' as 'Org1'" "U1F618"
      chaincodeCommit "cli.org1.ac.id" "peer0.org1.ac.id:7041" "storage-channel" "storage-chaincode" "$version" "orderer0.orderer.orderer.ac.id:7030" "" "false" "" "peer0.org1.ac.id:7041" "" ""

    else
      echo "Warning! Skipping chaincode 'storage-chaincode' upgrade. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/storage-chaincode'"
    fi
  fi
}

notifyOrgsAboutChannels() {
  printHeadline "Creating new channel config blocks" "U1F537"
  createNewChannelUpdateTx "storage-channel" "Org1MSP" "StorageChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"

  printHeadline "Notyfing orgs about channels" "U1F4E2"
  notifyOrgAboutNewChannel "storage-channel" "Org1MSP" "cli.org1.ac.id" "peer0.org1.ac.id" "orderer0.orderer.orderer.ac.id:7030"

  printHeadline "Deleting new channel config blocks" "U1F52A"
  deleteNewChannelUpdateTx "storage-channel" "Org1MSP" "cli.org1.ac.id"
}

printStartSuccessInfo() {
  printHeadline "Done! Enjoy your fresh network" "U1F984"
}

stopNetwork() {
  printHeadline "Stopping network" "U1F68F"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose stop)
  sleep 4
}

networkDown() {
  printHeadline "Destroying network" "U1F916"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose down)

  printf "\nRemoving chaincode containers & images... \U1F5D1 \n"
  for container in $(docker ps -a | grep "dev-peer0.org1.ac.id-storage-chaincode" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.org1.ac.id-storage-chaincode*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done

  printf "\nRemoving generated configs... \U1F5D1 \n"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/crypto-config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"

  printHeadline "Done! Network was purged" "U1F5D1"
}
