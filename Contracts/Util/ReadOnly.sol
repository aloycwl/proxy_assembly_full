// SPDX-License-Identifier: None
pragma solidity ^0.8.19;
pragma abicoder v1;

contract ReadOnly {
    function getSelector(string memory a) external pure returns(bytes4) {
        return bytes4(keccak256(abi.encodePacked(a)));
    }

    function getKeccak256(string memory a) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(a));
    }

    function hex2Uint(bytes memory a) external pure returns(uint b) {
        for(uint i = 0; i < a.length; ++i) b += uint(uint8(a[i]))*(2**(8*(a.length-i-1)));
    }

    function uint2Hex(uint a) external pure returns (bytes memory b) {
        uint len;
        for (uint i = a; i > 0; i /= 256) ++len;
        b = new bytes(len);
        for (uint i = 0; i < len; ++i) b[len-i-1] = bytes1(uint8(a / (2**(8*i))));
    }
}