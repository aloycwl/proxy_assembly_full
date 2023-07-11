//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract Stringy {

    function storeString(string memory str) external {
        assembly {
            sstore(0x20, mload(add(str, 0x20)))
            sstore(0x40, mload(add(str, 0x40)))
        }
    }
    //bafkreihm5kqas5md324fwjlgaeeoctc23w3mrqpju3k42roz7vmegwhvve

    function fetch_string() external view returns(string memory val) {
        assembly {
            val := mload(0x40)
            mstore(0x40, add(val, 0x60))
            mstore(val, 0x40)
            mstore(add(val, 0x40), sload(0x40))
            mstore(add(val, 0x20), sload(0x20))
        }
        
    }
}