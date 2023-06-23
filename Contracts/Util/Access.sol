//SPDX-License-Identifier:None
pragma solidity ^0.8.0;

//置对合约的访问
contract Access {

    mapping(address => uint) public addrs;

    //立即授予创建者访问权限
    constructor () {

        addrs[msg.sender] = 1e3;

    }

    //用作函数的修饰符
    modifier OnlyAccess () {

        require(addrs[msg.sender] > 0,          "Insufficient access");
        _;

    }

    //只可以管理权限币你小的人和授权比自己低的等级
    function setAccess (address addr, uint u) external OnlyAccess {

        uint acc = addrs[msg.sender];

        //不能修改访问权限高于用户的地址和授予高于自己的访问权限
        require(acc > addrs[addr] && acc > u,   "Invalid access");

        addrs[addr] = u;

    }
    
}