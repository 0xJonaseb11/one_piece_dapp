// import necessary modules
const { ethers } = require("hardhat");
const { fs } = require("fs");
const { dotenv } = require("dotenv");

// Load environment variables from .env file
dotenv.config();

// Main function to deploy contract
const main = async () => {
  // get the deployer's address
  const deployer = await ethers.getSigners();
  console.log("Deploying contract with account:", deployer.address);

  // Get necessary parameters from the .env 
  const vrfCoordinatorV2Address = process.env.VRF_ADDRESS;
  const subId = process.env.SUB_ID;
  const keyHash = process.env.KEY_HASH;
  const gasLimit = 2000000;

  // Prepare arguments array for contract deployment
  const argumentsArray = [vrfCoordinatorV2Address, subId, keyHash, gasLimit];

  // convert arguments array to string and save it to file
  const content = "module.exports = " +JSON.stringify(argumentsArray, null, 2) +";";
  fs.writeFileSync("./arguments.js", content);
  console.log("Arguments.js file generated successfully");

  // Deploy contract with provided arguments
  const onePiecePersonalityDapp = await onePiecePersonalityDapp.deploy(
    vrfCoordinatorV2Address,
    subId,
    keyHash,
    gasLimit
  );

  // Log the address where contract is deployed
  console.log("OnePiecePersonalityDapp deployed to:", await onePiecePersonalityDapp.getAddress());

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
  

}