//SPDX-License-Identifier:None
pragma solidity ^0.8.20;

import "./Util.sol";
import "./Interfaces.sol";

//代币合约
contract ERC20 is Util {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    uint public totalSupply;
    uint8 public suspended;
    uint8 public constant decimals = 18;
    string public symbol;
    string public name;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping (address => uint)) public allowance;
    IProxy public iProxy;
    //ERC20基本函数 
    constructor(address proxy, address receiver, uint amt, 
        string memory _name, string memory _symbol) Util() {
        (iProxy, symbol, name) = (IProxy(proxy), _symbol, _name);
        mint(amt, receiver);
    }
    function approve(address to, uint amt) external returns (bool) {
        emit Approval(msg.sender, to, allowance[msg.sender][to] = amt);
        return true;
    }
    function transfer(address to, uint amt) external returns (bool) {
        return transferFrom(msg.sender, to, amt);
    }
    function transferFrom(address from, address to, uint amt) public returns (bool) {
        unchecked {
            require(balanceOf[from] >= amt, "Insufficient balance");
            require(from == msg.sender || allowance[from][to] >= amt, "Insufficient allowance");
            require(IDID(iProxy.addrs(3)).uintData(from, 0) == 0 && 
                IDID(iProxy.addrs(3)).uintData(to, 0) == 0, "Account suspended");
            require(suspended == 0, "Contract suspended");
            
            if (allowance[from][to] >= amt) allowance[from][to] -= amt;
            (balanceOf[from] -= amt, balanceOf[to] += amt);
            emit Transfer(from, to, amt);
            return true;
        }
    }
    //管理功能
    function toggleSuspend() external OnlyAccess {
        suspended = suspended == 0 ? 1 : 0;
    }
    function mint(uint amt, address addr) public OnlyAccess {
        unchecked {
            (totalSupply += amt, balanceOf[addr] += amt);
            emit Transfer(address(this), addr, amt);
        }
    }
    function burn(uint amt) external OnlyAccess {
        unchecked {
            require(balanceOf[msg.sender] >= amt, "Insufficient balance");
            transferFrom(msg.sender, address(0), amt);
            totalSupply -= amt;
        }
    }
}