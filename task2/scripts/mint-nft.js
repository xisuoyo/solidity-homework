// scripts/mint-nft.js
const { ethers } = require("hardhat");

async function main() {
  // 替换成你部署的 MyNFT 合约地址
  const nftContractAddress = "0x2F08C56Af1D9aA7A5BD30A093Cbbe36C14B160f6"; // <-- 切换回旧的合约地址

  // 获取部署者的Signer（也是合约的owner，因为mintNFT是onlyOwner）
  const [owner] = await ethers.getSigners();

  // 获取 MyNFT 合约的实例
  const MyNFT = await ethers.getContractFactory("MyNFT");
  const myNFT = await MyNFT.attach(nftContractAddress);

  console.log("正在使用以下地址铸造NFT:", owner.address);

  // 铸造NFT的接收者地址 (通常是你的钱包地址)
  const recipientAddress = owner.address; // 将NFT铸造给自己（合约所有者）

  // NFT的元数据URI (之前从IPFS上传的JSON文件的链接)
  const tokenURI = "ipfs://bafkreigkoj6ftj4nq44tqrgkrmyzgehpwwn3m6xr2wha5s27sgso7khei4"; // <-- 你的元数据IPFS链接

  console.log(`正在铸造NFT到地址: ${recipientAddress}，元数据URI: ${tokenURI}`);

  // 调用 mintNFT 函数
  const tx = await myNFT.mintNFT(recipientAddress, tokenURI);
  await tx.wait(); // 等待交易被确认

  console.log(`NFT 已成功铸造！Token ID: ${await myNFT.totalSupply() - 1}`); // 获取新铸造的Token ID
  console.log(`请稍候在 OpenSea 测试网或 Etherscan 测试网查看你的NFT。`);
}

// 运行铸造脚本
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });