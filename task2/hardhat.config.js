require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

module.exports = {
  solidity: "0.8.19",
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
      gas: 30000000,
      gasPrice: 8000000000,
      timeout: 60000,
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20,
        accountsBalance: "10000000000000000000000"
      }
    },
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/Eppatmc-er8Su-9eid1-ZMF95huWV823",
      accounts: ["eb261ee7254c7754e5bf2503a35321885cc1c23e188d1ebf017ab82f590baea3"],
      chainId: 11155111
    }
  },
  etherscan: {
    apiKey: "37RJ3K5DNMVY55UZNTGMMTP1U14NIBF8AS"
  }
  // myNFT: 0x2F08C56Af1D9aA7A5BD30A093Cbbe36C14B160f6
  // myNFT: 0x3c344A87BC17cfa1837Eb4D27613A6607B2D4dA3
  // MyToken: 0x6f4Ff10174d9B1F2cC572B0d7D446d99513eb214
  // BeggingContract: 0x9532F7c128569F6098276625fE271Fd9577c32a9
}; 