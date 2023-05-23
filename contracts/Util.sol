//SPDX-License-Identifier:None
pragma solidity 0.8.18;

//置对合约的访问
contract Util {

    mapping(address => uint) public access;

    //立即授予创建者访问权限
    constructor() {
        access[msg.sender] = 1e3;
    }

    //用作函数的修饰符
    modifier OnlyAccess() {
        require(access[msg.sender] > 0, "Insufficient access");
        _;
    }

    //只可以管理权限币你小的人和授权比自己低的等级
    function setAccess(address addr, uint u) external OnlyAccess {
        unchecked{
            uint acc = access[msg.sender];

            require(acc > access[addr]  //不能修改访问权限高于用户的地址
                && acc > u,             //不能授予高于自己的访问权限
                "Invalid access");

            access[addr] = u;
        }
    }
}