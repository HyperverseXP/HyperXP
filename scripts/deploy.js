const { ethers, upgrades } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    // some fake loot?
    // const fLoot = await ethers.getContractFactory("FLoot");
    // const floot = await fLoot.deploy();

    // const Mana = await ethers.getContractFactory("CrystalsMetadata");
    // const mana = await Mana.deploy('0xA0712dD2a0591785D173EdB88535CAA42023efc9');
    // console.log("Mana address:", mana.address);


    const HyperXP = await ethers.getContractFactory("HyperXP");
    // const Client = await ethers.getContractFactory("HXPClient");
  
    const hyperxp = await HyperXP.deploy();
  
    console.log("HyperXP address:", hyperxp.address);

    // const client = await Client.deploy();

    // console.log("Client addres: ", client.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });