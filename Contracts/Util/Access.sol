//SPDX-License-Identifier:None
pragma solidity 0.8.18;

//置对合约的访问
contract Access {

    mapping(address => uint) public access;

    //立即授予创建者访问权限
    constructor() {

        access[msg.sender] = 1e3;

        /*assembly {
            // Store the uint value in the mapping
            sstore(add(access.slot, calldataload(0x00)), 1000)
        }*/

    }

    //用作函数的修饰符
    modifier OnlyAccess() {

        require(access[msg.sender] > 0,         "Insufficient access");
        _;

    }

    //只可以管理权限币你小的人和授权比自己低的等级
    function setAccess(address addr, uint u) external OnlyAccess {

        uint acc = access[msg.sender];

        //不能修改访问权限高于用户的地址和授予高于自己的访问权限
        require(acc > access[addr] && acc > u,  "Invalid access");

        access[addr] = u;

    }
    
}