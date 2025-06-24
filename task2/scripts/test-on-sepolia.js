const { ethers } = require("hardhat");

async function main() {
  // 获取合约地址（请替换为你的实际部署地址）
  const contractAddress = "0x6f4Ff10174d9B1F2cC572B0d7D446d99513eb214";
  const MyToken = await ethers.getContractFactory("MyToken");
  const myToken = await MyToken.attach(contractAddress);

  console.log("开始测试合约功能...");

  // 获取当前账户
  const [owner] = await ethers.getSigners();
  console.log("测试账户地址:", owner.address);

  // 测试查询代币名称和符号
  const name = await myToken.name();
  const symbol = await myToken.symbol();
  console.log("代币名称:", name);
  console.log("代币符号:", symbol);

  // 测试查询余额
  const balance = await myToken.balanceOf(owner.address);
  console.log("当前账户余额:", ethers.utils.formatEther(balance), "MTK");

  // 获取总供应量
  const totalSupply = await myToken.totalSupply();
  console.log("代币总供应量:", ethers.utils.formatEther(totalSupply), "MTK");
}

main().catch((error) => {
  console.error("测试失败:", error);
  process.exitCode = 1;
}); 