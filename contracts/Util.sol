//SPDX-License-Identifier:None
pragma solidity ^0.8.20;

//置对合约的访问
contract Util {
    mapping(address => uint) public access;

    constructor() {
        access[msg.sender] = 1e3;
    }
    modifier OnlyAccess() {
        require(access[msg.sender] > 0, "Insufficient access");
        _;
    }
    //只可以管理权限币你小的人和授权比自己低的等级
    function setAccess(address addr, uint u) external OnlyAccess {
        unchecked{
            uint acc = access[msg.sender];
            require(acc > access[addr] && acc > u, "Invalid access");
            access[addr] = u;
        }
    }
}