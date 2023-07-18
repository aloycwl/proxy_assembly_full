//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

contract TestString {

function tokenURI() public pure returns (string memory) {
        assembly {
            let str := "HELLO "

            mstore(0xa0, "SOME STRING")

            mstore(0x80, 0x20)
            mstore(0xa0, 0x2b)
            mstore(0xc0, str)
            mstore(0xe0, mload(0x0))
            return(0x80, 0x80)
        }
    }
}