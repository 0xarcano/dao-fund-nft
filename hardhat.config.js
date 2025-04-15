//const { network } = require("hardhat");
require('dotenv').config();
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.4",
  networks: {
    sepolia: {
      url: 'https://eth-sepolia.g.alchemy.com/v2/-GSf2baqVrXPNWP1nN5tS2diSO7EU-Bc',
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    hoodi: {
      url: 'https://eth-hoodi.g.alchemy.com/v2/-GSf2baqVrXPNWP1nN5tS2diSO7EU-Bc',
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  },
};
