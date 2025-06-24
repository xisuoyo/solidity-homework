const { ethers } = require("hardhat");

async function main() {
  // 合约地址
  const contractAddress = "0x6f4Ff10174d9B1F2cC572B0d7D446d99513eb214";
  // 接收方地址（使用 Ganache 的第一个测试账户）
  const to = "0xE61Ee479849E07D9Dfc9948b44f6fc791932d39a";
  // 转账数量（1个代币）
  const amount = ethers.utils.parseEther("1.0");

  const MyToken = await ethers.getContractFactory("MyToken");
  const myToken = await MyToken.attach(contractAddress);

  console.log("开始转账...");
  const tx = await myToken.transfer(to, amount);
  console.log("交易已发送，等待确认...");
  
  await tx.wait();
  console.log("转账成功！");
  console.log("交易哈希:", tx.hash);
}

main().catch((error) => {
  console.error("转账失败:", error);
  process.exitCode = 1;
}); 