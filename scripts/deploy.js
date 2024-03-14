// Import necessary modules
const { ethers } = require("hardhat");
const fs = require("fs");
const dotenv = require("dotenv");

// Load environment variables from .env file
dotenv.config();

// Main function to deploy contracts
const main = async () => {

  // Get the deployer's signer
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Get the necessary parameters from environment variables
  const vrfCoordinatorV2Address = process.env.VRF_ADDRESS; 
  const subId = process.env.SUB_ID; 
  const keyHash = process.env.KEY_HASH;
  const gasLimit = 2000000;

  // Prepare arguments array for contract deployment
  const argumentsArray = [vrfCoordinatorV2Address, subId, keyHash, gasLimit ]

  // Convert arguments array to string and save it to a file
  const content = "module.exports = " + JSON.stringify(argumentsArray, null, 2) + ";";
  fs.writeFileSync("./arguments.js", content);
  console.log("arguments.js file generated successfully.");

  // Deploying OnePiecePersonalityDapp contract
  const OnePiecePersonalityDapp = await ethers.getContractFactory("OnePieceMint");
  console.log("Deploying OnePiecePersonalityDapp...");

  // Deploy the contract with provided arguments
  const onePiecePersonalityDapp = await OnePiecePersonalityDapp.deploy(
    vrfCoordinatorV2Address,
    subId,
    keyHash,
    gasLimit);

  // Log the address where the contract is deployed
  console.log("OnePiecePersonalityDapp deployed to:", await onePiecePersonalityDapp.getAddress());
}

// Execute the main function
const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error("Error deploying contract:", error);
    process.exit(1);
  }
}

runMain();