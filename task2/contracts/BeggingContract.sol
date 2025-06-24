// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


// Sepolia合约地址：0x9532F7c128569F6098276625fE271Fd9577c32a9
// BeggingContract 合约继承了 Ownable (所有者控制)
contract BeggingContract is Ownable {
    // mapping：记录每个捐赠者的地址和他们捐赠的总金额
    mapping(address => uint256) public donations;

    // 事件：每次成功捐赠时触发，记录捐赠者地址和金额
    event Donation(address indexed donor, uint256 amount);

    // 用于跟踪所有唯一的捐赠者地址，以便生成排行榜
    address[] private donorAddresses;
    // 用于快速检查一个地址是否已经存在于 donorAddresses 数组中
    mapping(address => bool) private isDonor;

    uint256 public startTime;
    uint256 public endTime;

    // 构造函数：部署合约的地址将成为合约所有者
    constructor() Ownable() {}

    function setDonationPeriod(uint256 _startTime, uint256 _endTime) public onlyOwner {
        // 允许 _startTime 和 _endTime 都为 0，表示禁用时间限制
        require(_endTime >= _startTime, "End time must be after or equal to start time.");
        startTime = _startTime;
        endTime = _endTime;
    }

    // donate 函数：允许用户向合约发送以太币
    // payable 修饰符表示此函数可以接收以太币
    function donate() public payable {
        // 检查当前时间是否在捐赠期间 (如果 startTime 或 endTime 为 0 则不检查)
        if (startTime > 0 && endTime > 0) {
            require(block.timestamp >= startTime && block.timestamp <= endTime, "Donations are currently closed or not yet open.");
        }
        
        // 要求发送的以太币金额大于0
        require(msg.value > 0, "Donation amount must be greater than zero.");

        // 如果是新的捐赠者，将其地址添加到 donorAddresses 数组
        if (!isDonor[msg.sender]) {
            isDonor[msg.sender] = true;
            donorAddresses.push(msg.sender);
        }

        // 记录捐赠者的地址和捐赠金额
        donations[msg.sender] += msg.value;
        // 触发 Donation 事件
        emit Donation(msg.sender, msg.value);
    }

    // withdraw 函数：允许合约所有者提取所有捐赠的资金
    // onlyOwner 修饰符限制此函数只能由合约所有者调用
    function withdraw() public onlyOwner {
        // 要求合约中有资金可供提取
        require(address(this).balance > 0, "No funds to withdraw.");
        // 将合约中的所有资金转账给所有者
        payable(owner()).transfer(address(this).balance);
    }

    // getDonation 函数：允许查询某个地址的捐赠金额
    // public view 修饰符表示此函数是只读的，不消耗 Gas
    function getDonation(address donor) public view returns (uint256) {
        return donations[donor];
    }

    // 排行榜条目结构体
    struct LeaderboardEntry {
        address donor;
        uint256 amount;
    }

    // 获取捐赠金额前 3 名的地址和金额
    // 此函数会遍历所有捐赠者，并找出前 3 名，对于少量数据是可接受的
    function getTop3Donors() public view returns (LeaderboardEntry[3] memory) {
        LeaderboardEntry[3] memory top3; // 初始化为0

        // 遍历所有捐赠者地址
        for (uint i = 0; i < donorAddresses.length; i++) {
            address currentDonor = donorAddresses[i];
            uint256 currentAmount = donations[currentDonor];

            // 如果当前捐赠金额大于当前第一名
            if (currentAmount > top3[0].amount) {
                top3[2] = top3[1]; // 第三名变为第二名
                top3[1] = top3[0]; // 第二名变为第一名
                top3[0] = LeaderboardEntry(currentDonor, currentAmount); // 当前成为第一名
            }
            // 如果当前捐赠金额大于当前第二名 (且不大于第一名)
            else if (currentAmount > top3[1].amount) {
                top3[2] = top3[1]; // 第三名变为第二名
                top3[1] = LeaderboardEntry(currentDonor, currentAmount); // 当前成为第二名
            }
            // 如果当前捐赠金额大于当前第三名 (且不大于第一、二名)
            else if (currentAmount > top3[2].amount) {
                top3[2] = LeaderboardEntry(currentDonor, currentAmount); // 当前成为第三名
            }
        }
        return top3;
    }
}