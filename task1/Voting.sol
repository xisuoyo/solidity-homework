// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    // 存储候选人得票数的mapping
    mapping(string => uint256) public votes;
    
    // 存储所有候选人列表
    string[] public candidates;
    
    // 合约拥有者
    address public owner;
    
    // 事件：记录投票
    event Voted(address voter, string candidate, uint256 newVoteCount);
    
    // 事件：记录重置
    event VotesReset();
    
    constructor() {
        owner = msg.sender;
    }
    
    // 添加候选人
    function addCandidate(string memory _name) public {
        require(msg.sender == owner, "Only owner can add candidates");
        candidates.push(_name);
    }
    
    // 投票函数
    function vote(string memory _candidate) public {
        // 检查候选人是否存在
        bool candidateExists = false;
        for(uint i = 0; i < candidates.length; i++) {
            if(keccak256(bytes(candidates[i])) == keccak256(bytes(_candidate))) {
                candidateExists = true;
                break;
            }
        }
        require(candidateExists, "Candidate does not exist");
        
        // 增加票数
        votes[_candidate]++;
        
        // 触发投票事件
        emit Voted(msg.sender, _candidate, votes[_candidate]);
    }
    
    // 获取候选人得票数
    function getVotes(string memory _candidate) public view returns (uint256) {
        return votes[_candidate];
    }
    
    // 重置所有候选人的得票数
    function resetVotes() public {
        require(msg.sender == owner, "Only owner can reset votes");
        
        for(uint i = 0; i < candidates.length; i++) {
            votes[candidates[i]] = 0;
        }
        
        // 触发重置事件
        emit VotesReset();
    }
    
    // 获取所有候选人
    function getCandidates() public view returns (string[] memory) {
        return candidates;
    }
} 