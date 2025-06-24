// scripts/deploy-mynft.js
const { ethers } = require("hardhat");

async function main() {
  // 获取部署者的Signer
  const [deployer] = await ethers.getSigners();

  console.log("正在使用以下地址部署合约:", deployer.address);
  console.log("账户余额:", (await deployer.getBalance()).toString());

  // 获取合约工厂
  const MyNFT = await ethers.getContractFactory("MyNFT");

  // 部署合约，传入名称和符号
  // 名称和符号可以根据你的NFT项目自定义
  const name = "MyAwesomeNFT";
  const symbol = "MAN";
  const myNFT = await MyNFT.deploy(name, symbol);

  // 等待合约部署完成
  await myNFT.deployed();

  console.log("MyNFT 合约部署到:", myNFT.address);
}

// 运行部署脚本
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });