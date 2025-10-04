require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.28",
  networks: {
    hardhat: {
      chainId: 1337
    },
    sepolia: {
      url: "https://eth-sepolia.public.blastapi.io",
      chainId: 11155111,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    }
  }
};