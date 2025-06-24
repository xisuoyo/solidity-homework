// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts-ccip/src/v0.8/CCIPSender.sol";
import "@chainlink/contracts-ccip/src/v0.8/CCIPReceiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ProxyAuction is CCIPSender, CCIPReceiver, Ownable {
    address public mainAuction;
    uint64 public mainChainSelector;
    address public linkToken;

    event BidSent(address bidder, address paymentToken, uint256 amount, uint256 fromChain);
    event Settlement(address winner, address paymentToken, uint256 amount, address seller);

    constructor(
        address _router,
        address _linkToken,
        address _mainAuction,
        uint64 _mainChainSelector
    ) CCIPSender(_router) CCIPReceiver(_router) {
        linkToken = _linkToken;
        mainAuction = _mainAuction;
        mainChainSelector = _mainChainSelector;
    }

    // 用户在本链出价
    function bid(address paymentToken, uint256 amount) external payable {
        if (paymentToken == address(0)) {
            require(msg.value == amount, "ETH amount mismatch");
        } else {
            IERC20(paymentToken).transferFrom(msg.sender, address(this), amount);
        }
        // 构造CCIP消息，增加本合约地址
        bytes memory data = abi.encode(msg.sender, paymentToken, amount, block.chainid, address(this));
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(mainAuction),
            data: data,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: linkToken
        });
        uint256 fee = this.getFee(mainChainSelector, message);
        require(IERC20(linkToken).transferFrom(msg.sender, address(this), fee), "Pay LINK fee");
        this.ccipSend{value: 0}(mainChainSelector, message);
        emit BidSent(msg.sender, paymentToken, amount, block.chainid);
    }

    // 可选：接收主链的拍卖结果
    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        // 解析主链结算消息，自动将资金转给卖家
        (address winner, address paymentToken, uint256 amount, address seller) = abi.decode(message.data, (address, address, uint256, address));
        require(winner == msg.sender, "Only winner can settle");
        if (paymentToken == address(0)) {
            payable(seller).transfer(amount);
        } else {
            IERC20(paymentToken).transfer(seller, amount);
        }
        emit Settlement(winner, paymentToken, amount, seller);
    }
} 