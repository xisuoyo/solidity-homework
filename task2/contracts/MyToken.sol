// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    error NotOwner();
    error ZeroAddress();
    error InsufficientBalance();
    error InsufficientAllowance();

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        if (to == address(0)) revert ZeroAddress();
        if (_balances[msg.sender] < amount) revert InsufficientBalance();

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        if (spender == address(0)) revert ZeroAddress();

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        if (to == address(0)) revert ZeroAddress();
        if (_balances[from] < amount) revert InsufficientBalance();
        if (_allowances[from][msg.sender] < amount) revert InsufficientAllowance();

        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        if (to == address(0)) revert ZeroAddress();

        totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }
} 