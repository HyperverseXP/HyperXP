/**
 * @type import('hardhat/config').HardhatUserConfig
 */

require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
require("@nomiclabs/hardhat-etherscan");

const ROPSTEN_PK = process.env.ROPSTEN_PK;
const ALCHEMY_URL_ROP = process.env.ALCHEMY_URL_ROPSTEN;

module.exports = {
  solidity: "0.8.9",
  networks: {
    ropsten: {
      url: ALCHEMY_URL_ROP,
      accounts: [`${ROPSTEN_PK}`]
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API
  }
};
