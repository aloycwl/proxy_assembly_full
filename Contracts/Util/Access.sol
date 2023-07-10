//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

//置对合约的访问
contract Access {

    //立即授予创建者访问权限
    constructor() {

        //access[msg.sender] = 0xFF;
        assembly {
            mstore(0x00, origin())
            sstore(keccak256(0x00, 0x20), 0xFF)
        }

    }

    //用作函数的修饰符
    modifier OnlyAccess() {

        //require(access[msg.sender] > 0, "01");
        assembly {
            mstore(0x00, origin())
            if iszero(sload(keccak256(0x00, 0x20))) {
                revert(0x00, 0x00)
            }
        }
        _;

    }

    //只可以管理权限币你小的人和授权比自己低的等级
    function setAccess(address addr, uint u) external OnlyAccess {

        //access[addr] = u;
        assembly {
            mstore(0x00, addr)
            sstore(keccak256(0x00, 0x20), u)
        }
        
    }

    function access(address addr) external view returns(uint) {

        //mapping(address => uint) public access;
        assembly {
            mstore(0x00, addr)
            mstore(0x20, sload(keccak256(0x00, 0x20)))
            return(0x20, 0x20)
        }

    }
    
}