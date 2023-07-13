//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

//置对合约的访问
contract Access {

    //立即授予创建者访问权限
    constructor() {
        assembly { //access[msg.sender] = 0xFF;
            mstore(0x00, origin())
            sstore(keccak256(0x00, 0x20), 0xFF)
        }
    }

    //用作函数的修饰符
    modifier OnlyAccess() {
        assembly { //require(access[msg.sender] > 0, "01");
            mstore(0x00, origin())
            if iszero(sload(keccak256(0x00, 0x20))) {
                revert(0x00, 0x00)
            }
        }
        _;
    }

    //只可以管理权限币你小的人和授权比自己低的等级
    function setAccess(address addr, uint u) external OnlyAccess {
        assembly { //access[addr] = u;
            mstore(0x00, addr)
            sstore(keccak256(0x00, 0x20), u)
        }
    }

    function access(address addr) external view returns(uint val) {
        assembly { //mapping(address => uint) public access;
            mstore(0x00, addr)
            val := sload(keccak256(0x00, 0x20))
        }
    }
}