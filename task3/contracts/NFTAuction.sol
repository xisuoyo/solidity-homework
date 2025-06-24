// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTAuction is ReentrancyGuard {
    struct Auction {
        address seller;
        address nftAddress;
        uint256 tokenId;
        address paymentToken; // address(0) 表示ETH
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool ended;
    }

    uint256 public auctionCount;
    mapping(uint256 => Auction) public auctions;

    event AuctionCreated(uint256 auctionId, address seller, address nft, uint256 tokenId, address paymentToken, uint256 endTime);
    event BidPlaced(uint256 auctionId, address bidder, uint256 amount);
    event AuctionEnded(uint256 auctionId, address winner, uint256 amount);

    // 创建拍卖
    function createAuction(
        address nftAddress,
        uint256 tokenId,
        address paymentToken,
        uint256 startingBid,
        uint256 duration
    ) external {
        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenId);

        auctionCount++;
        auctions[auctionCount] = Auction({
            seller: msg.sender,
            nftAddress: nftAddress,
            tokenId: tokenId,
            paymentToken: paymentToken,
            highestBid: startingBid,
            highestBidder: address(0),
            endTime: block.timestamp + duration,
            ended: false
        });

        emit AuctionCreated(auctionCount, msg.sender, nftAddress, tokenId, paymentToken, block.timestamp + duration);
    }

    // 出价
    function bid(uint256 auctionId, uint256 amount) external payable nonReentrant {
        Auction storage auction = auctions[auctionId];
        require(block.timestamp < auction.endTime, "Auction ended");
        require(!auction.ended, "Auction already ended");

        if (auction.paymentToken == address(0)) {
            // ETH 出价
            require(msg.value > auction.highestBid, "Bid too low");
            if (auction.highestBidder != address(0)) {
                // 退还上一个出价者
                payable(auction.highestBidder).transfer(auction.highestBid);
            }
            auction.highestBid = msg.value;
        } else {
            // ERC20 出价
            require(amount > auction.highestBid, "Bid too low");
            IERC20(auction.paymentToken).transferFrom(msg.sender, address(this), amount);
            if (auction.highestBidder != address(0)) {
                // 退还上一个出价者
                IERC20(auction.paymentToken).transfer(auction.highestBidder, auction.highestBid);
            }
            auction.highestBid = amount;
        }
        auction.highestBidder = msg.sender;

        emit BidPlaced(auctionId, msg.sender, auction.highestBid);
    }

    // 结束拍卖
    function endAuction(uint256 auctionId) external nonReentrant {
        Auction storage auction = auctions[auctionId];
        require(block.timestamp >= auction.endTime, "Auction not ended");
        require(!auction.ended, "Already ended");

        auction.ended = true;
        // 转移 NFT
        IERC721(auction.nftAddress).transferFrom(address(this), auction.highestBidder, auction.tokenId);

        // 转移资金
        if (auction.paymentToken == address(0)) {
            payable(auction.seller).transfer(auction.highestBid);
        } else {
            IERC20(auction.paymentToken).transfer(auction.seller, auction.highestBid);
        }

        emit AuctionEnded(auctionId, auction.highestBidder, auction.highestBid);
    }
}