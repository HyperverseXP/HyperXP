const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const HyperXP = await ethers.getContractFactory("HyperXP");
    const Client = await ethers.getContractFactory("HXPClient");
  
    const hyperxp = await HyperXP.deploy();
  
    console.log("HyperXP address:", hyperxp.address);

    const client = await Client.deploy();

    console.log("Client addres: ", client.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });