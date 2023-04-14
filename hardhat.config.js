/**
 * @type import('hardhat/config').HardhatUserConfig
 */

require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
require("@nomiclabs/hardhat-etherscan");
// require('@openzeppelin/hardhat-upgrades');
require('hardhat-contract-sizer');

const ROPSTEN_PK = process.env.ROPSTEN_PK;
const ALCHEMY_URL_ROP = process.env.ALCHEMY_URL_ROPSTEN;
const ALCHEMY_URL_GOERLI = process.env.ALCHEMY_URL_GOERLI;

module.exports = {
  solidity: "0.8.9",
  networks: {
    ropsten: {
      url: ALCHEMY_URL_ROP,
      accounts: [`${ROPSTEN_PK}`]
    },
    goerli: {
      url: ALCHEMY_URL_GOERLI,
      accounts: [`${ROPSTEN_PK}`],
      gas: 2100000,
       gasPrice: 8000000000,
       saveDeployments: true,
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API
  },
  settings: {
    optimizer: { 
      enabled: true,
      runs: 10
    }
  }
};
