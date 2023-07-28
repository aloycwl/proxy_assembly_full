// SPDX-License-Identifier: None
pragma solidity ^0.8.18;

contract TEST {
    function getSelector(string memory a) external pure returns(bytes4) {
        return bytes4(keccak256(abi.encodePacked(a)));
    }

    function getKeccak256(string memory a) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(a));
    }

    function convertAddr2Uint(address a) external pure returns(uint val) {
        assembly {
            val := a
        }
    }

    function convertUint2Addr(uint a) external pure returns(address val) {
        assembly {
            val := a
        }
    }
}