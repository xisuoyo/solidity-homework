const { ethers } = require("hardhat");

async function main() {
  // 合约地址，替换为你的实际部署地址
  const contractAddress = "0x6f4Ff10174d9B1F2cC572B0d7D446d99513eb214";
  // mint 目标地址，通常是 owner
  const to = "0x64D8Cc033A0c6181f11c1908e59097Def8107D16";
  // mint 数量，这里是 1000 个代币（假设是 18 位小数）
  const amount = ethers.utils.parseEther("1000");

  const MyToken = await ethers.getContractFactory("MyToken");
  const myToken = await MyToken.attach(contractAddress);

  const tx = await myToken.mint(to, amount);
  await tx.wait();

  console.log(`成功给 ${to} 铸造了 ${ethers.utils.formatEther(amount)} 个代币！`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
}); 