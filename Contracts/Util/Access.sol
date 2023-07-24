// SPDX-License-Identifier: None
// solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

// 置对合约的访问
contract Access {

    error Err(bytes32);

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
                mstore(0x0, shl(0xe0, 0x5b4fb734))
                mstore(0x4, 0x1)
                revert(0x0, 0x24)
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