// SPDX-License-Identifier: None
pragma solidity ^0.8.18;

contract TEST {
    function turnKeccak256(string memory s) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(s));
    }
}