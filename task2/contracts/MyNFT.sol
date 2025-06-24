// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// MyNFT 合约继承了 ERC721 (NFT标准) 和 Ownable (所有者控制)
contract MyNFT is ERC721URIStorage, Ownable {
    // 使用Counters库来管理token ID，确保每个NFT都有唯一的ID
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // 构造函数：在部署合约时设置NFT的名称和符号
    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
        Ownable()
    {}

    // mintNFT 函数：允许合约所有者铸造新的NFT
    // 只有合约所有者 (Ownable) 可以调用此函数
    function mintNFT(address recipient, string memory tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        require(true, "Debug Check Passed"); // 添加这一行用于调试
        // 增加token ID计数器，为新NFT生成一个唯一的ID
        uint256 newItemId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        // 将新的NFT铸造给指定接收者
        _safeMint(recipient, newItemId);
        // 将NFT的元数据URI关联到这个NFT
        _setTokenURI(newItemId, tokenURI);

        // 返回新铸造的NFT的ID
        return newItemId;
    }

    // 添加一个公共函数来获取已铸造NFT的总数
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }
}