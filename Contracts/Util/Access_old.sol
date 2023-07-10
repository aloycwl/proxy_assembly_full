//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

//置对合约的访问
contract Access {

    mapping(address => uint) public access;

    //立即授予创建者访问权限
    constructor() {

        access[msg.sender] = 0xFF;

    }

    //用作函数的修饰符
    modifier OnlyAccess() {

        require(access[msg.sender] > 0, "01");
        _;

    }

    //只可以管理权限币你小的人和授权比自己低的等级
    function setAccess(address addr, uint u) external OnlyAccess {

        access[addr] = u;

    }
    
}