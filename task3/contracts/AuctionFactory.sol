// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Auction.sol";

contract AuctionFactory {
    // NFT合约地址 => tokenId => 拍卖合约地址
    mapping(address => mapping(uint256 => address)) public getAuction;
    address[] public allAuctions;

    event AuctionCreated(address indexed nft, uint256 indexed tokenId, address auction, address seller);

    function createAuction(
        address nftAddress,
        uint256 tokenId,
        uint256 startingBid,
        uint256 duration,
        address[] memory tokens,
        address[] memory feeds,
        address proxyAddress,
        uint64 proxyChainSelector,
        address router
    ) external returns (address auctionAddr) {
        require(getAuction[nftAddress][tokenId] == address(0), "AUCTION_EXISTS");
        Auction auction = new Auction(
            router,
            msg.sender,
            nftAddress,
            tokenId,
            startingBid,
            duration,
            tokens,
            feeds,
            proxyAddress,
            proxyChainSelector
        );
        getAuction[nftAddress][tokenId] = address(auction);
        allAuctions.push(address(auction));
        emit AuctionCreated(nftAddress, tokenId, address(auction), msg.sender);
        return address(auction);
    }

    function allAuctionsLength() external view returns (uint256) {
        return allAuctions.length;
    }

    function getAllAuctions() external view returns (address[] memory) {
        return allAuctions;
    }
} 