//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

contract TestString {

    function call(string memory u) external {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0xc7070b58)) // stringData(bytes32,bytes32,bytes32,bytes32,bytes32)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x24), 0x1)
            mstore(add(ptr, 0x44), mload(u))
            mstore(add(ptr, 0x64), mload(add(u, 0x20)))
            mstore(add(ptr, 0x84), mload(add(u, 0x40)))
            sstore(0x0, call(gas(), 0xE3Ca443c9fd7AF40A2B5a95d43207E763e56005F, 0x0, ptr, 0xa4, 0x0, 0x0))
        }
    }

    function result() external view returns(uint val){
        assembly {
            val := sload(0x0)
        }
    }
}

contract DID {
    function stringData(address a, uint b) external view returns(string memory val) { // 0x99eec064
        assembly{
            mstore(0x0, a)
            mstore(0x20, b)
            let d := keccak256(0x0, 0x40)
            val := mload(0x40)
            mstore(0x40, add(val, 0x60))
            mstore(val, sload(d))
            mstore(add(val, 0x20), sload(add(d, 0x20)))
            mstore(add(val, 0x40), sload(add(d, 0x40)))
        }
    }
    function stringData(bytes32 a, bytes32 b, bytes32 c, bytes32 d, bytes32 e) external { // 0xc7070b58
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            let f := keccak256(0x0, 0x40)
            sstore(f, c)
            sstore(add(f, 0x20), d)
            sstore(add(f, 0x40), e)
        }
    }
}