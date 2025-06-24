// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts-ccip/src/v0.8/CCIPReceiver.sol";

contract Auction is ReentrancyGuard, CCIPReceiver {
    address public seller;
    address public nftAddress;
    uint256 public tokenId;
    uint256 public highestBid;
    address public highestBidder;
    address public highestBidToken;
    uint256 public highestBidUsd;
    uint256 public highestBidChain;
    uint256 public endTime;
    bool public ended;
    address public highestBidProxy;

    mapping(address => address) public priceFeeds; // token => feed
    mapping(uint256 => address) public proxyAddressOfChain;
    event BidPlaced(address bidder, uint256 amount, uint256 usdValue, uint256 chainId);
    event AuctionEnded(address winner, uint256 amount, uint256 usdValue, uint256 chainId);

    constructor(
        address _router,
        address _seller,
        address _nftAddress,
        uint256 _tokenId,
        uint256 _startingBid,
        uint256 _duration,
        address[] memory tokens,
        address[] memory feeds
    ) CCIPReceiver(_router) {
        require(tokens.length == feeds.length, "tokens/feeds length mismatch");
        seller = _seller;
        nftAddress = _nftAddress;
        tokenId = _tokenId;
        highestBid = _startingBid;
        endTime = block.timestamp + _duration;
        for (uint i = 0; i < tokens.length; i++) {
            priceFeeds[tokens[i]] = feeds[i];
        }
        IERC721(nftAddress).transferFrom(seller, address(this), tokenId);
    }

    function getLatestPrice(address token) public view returns (uint256) {
        address feed = priceFeeds[token];
        require(feed != address(0), "No price feed for token");
        AggregatorV3Interface priceFeed = AggregatorV3Interface(feed);
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        return uint256(price); // 8位小数
    }

    function getBidUsdValue(address token, uint256 amount) public view returns (uint256) {
        uint256 price = getLatestPrice(token); // 8位小数
        if (token == address(0)) {
            return amount * price / 1e8;
        } else {
            uint8 decimals = IERC20Metadata(token).decimals();
            return amount * price / (10 ** decimals) / 1e8;
        }
    }

    function bid(address paymentToken, uint256 amount) external payable nonReentrant {
        _bid(msg.sender, paymentToken, amount, block.chainid, address(0));
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        (address bidder, address paymentToken, uint256 amount, uint256 fromChain, address proxyAddr) =
            abi.decode(message.data, (address, address, uint256, uint256, address));
        _bid(bidder, paymentToken, amount, fromChain, proxyAddr);
    }

    function _bid(address bidder, address paymentToken, uint256 amount, uint256 fromChain, address proxyAddr) internal {
        require(block.timestamp < endTime, "Auction ended");
        require(!ended, "Auction already ended");
        uint256 usdValue = getBidUsdValue(paymentToken, amount);
        require(usdValue > highestBidUsd, "Bid USD value too low");
        if (fromChain == block.chainid) {
            if (paymentToken == address(0)) {
                require(msg.value == amount, "ETH amount mismatch");
                if (highestBidder != address(0)) {
                    payable(highestBidder).transfer(highestBid);
                }
            } else {
                IERC20(paymentToken).transferFrom(bidder, address(this), amount);
                if (highestBidder != address(0)) {
                    IERC20(highestBidToken).transfer(highestBidder, highestBid);
                }
            }
        } else {
            // 跨链出价，资金由辅链托管，主链只记录出价
        }
        highestBid = amount;
        highestBidder = bidder;
        highestBidToken = paymentToken;
        highestBidUsd = usdValue;
        highestBidChain = fromChain;
        highestBidProxy = proxyAddr;
        emit BidPlaced(bidder, amount, usdValue, fromChain);
    }

    function setProxyAddress(uint256 chainSelector, address proxy) external {
        proxyAddressOfChain[chainSelector] = proxy;
    }

    function endAuction() external nonReentrant {
        require(block.timestamp >= endTime, "Auction not ended");
        require(!ended, "Already ended");
        ended = true;
        uint256 usdValue = getBidUsdValue(highestBidToken, highestBid);
        IERC721(nftAddress).transferFrom(address(this), highestBidder, tokenId);
        if (highestBidChain == block.chainid) {
            if (highestBidToken == address(0)) {
                payable(seller).transfer(highestBid);
            } else {
                IERC20(highestBidToken).transfer(seller, highestBid);
            }
        } else {
            // 跨链结算，直接用最高出价的proxyAuction地址
            require(highestBidProxy != address(0), "Proxy address not set");
            bytes memory data = abi.encode(highestBidder, highestBidToken, highestBid, seller);
            Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
                receiver: abi.encode(highestBidProxy),
                data: data,
                tokenAmounts: new Client.EVMTokenAmount[](0),
                extraArgs: "",
                feeToken: address(0)
            });
            this.ccipSend(uint64(highestBidChain), message);
        }
        emit AuctionEnded(highestBidder, highestBid, usdValue, highestBidChain);
    }
} 