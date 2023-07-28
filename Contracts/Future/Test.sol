// SPDX-License-Identifier: None
pragma solidity ^0.8.18;

contract TEST {
    function getSelector(string memory s) external pure returns(bytes4) {
        return bytes4(keccak256(abi.encodePacked(s)));
    }

    function getKeccak256(string memory s) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(s));
    }
}