// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

// 置对合约的访问
contract Access {

    bytes32 constant private ERR = 0x08c379a000000000000000000000000000000000000000000000000000000000;

    // 立即授予创建者访问权限
    constructor() {
        assembly { // access[msg.sender] = 0xff;
            sstore(origin(), 0xff)
        }
    }

    //用作函数的修饰符
    modifier OnlyAccess() {
        assembly { // require(access[msg.sender] > 0, 0x1);
            if iszero(sload(caller())) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x0e)
                mstore(0xC4, "Invalid access")
                //revert(0x80, 0x64)
            }
        }
        _;
    }

    //只可以管理权限币你小的人和授权比自己低的等级
    function setAccess(address addr, uint u) external OnlyAccess {
        assembly { // access[addr] = u;
            sstore(addr, u)
        }
    }

    function access(address addr) external view returns(uint val) {
        assembly { // mapping(address => uint) public access;
            val := sload(addr)
        }
    }
}