//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract arraywy {

    function uintEnum(address a, address b) external view returns (uint[] memory result) {

        uint len;
        
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            let ptr := keccak256(0x0, 0x40)
            mstore(0x0, ptr)
            len := sload(ptr)
            mstore(result, len)
        }

        result = new uint[](len);

        assembly {
            let ptr := keccak256(0x0, 0x20)
            for { let i := 0x0 } lt(i, len) { i := add(i, 0x1) } {
                mstore(add(result, mul(add(i, 0x1), 0x20)), sload(add(ptr, i)))
            }
        }
    }
    
    function uintEnumPush(address a, address b, uint c) external {
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            let ptr := keccak256(0x0, 0x40)
            let len := sload(ptr)
            sstore(ptr, add(len, 1))
            mstore(0x0, ptr)
            sstore(add(keccak256(0x0, 0x20), mul(len, 0x1)), c)
        }
    }

    function uintEnumPop(address a, address b, uint c) external {
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            let ptr := keccak256(0x0, 0x40)
            let len := sload(ptr)
            if iszero(gt(len, c)) {
                revert(0x0, 0x0)
            }
            sstore(ptr, sub(len, 1))
            mstore(0x0, ptr)
            ptr := keccak256(0x0, 0x20)
            sstore(add(ptr, c), sload(add(ptr, sub(len, 1))))
        }
    }

    
}