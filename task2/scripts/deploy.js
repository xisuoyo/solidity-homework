const { ethers } = require("hardhat");

async function main() {
  console.log("开始部署 MyToken 合约...");
  
  const MyToken = await ethers.getContractFactory("MyToken");
  const myToken = await MyToken.deploy("MyToken", "MTK");
  
  await myToken.deployed();
  
  console.log("MyToken 合约已部署到:", myToken.address);
  console.log("交易哈希:", myToken.deployTransaction.hash);
}

main().catch((error) => {
  console.error("部署失败:", error);
  process.exitCode = 1;
}); 