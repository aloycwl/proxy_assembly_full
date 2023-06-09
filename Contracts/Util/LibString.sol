//SPDX-License-Identifier:None
pragma solidity 0.8.18;

library LibString {

    function append(string memory a, string memory b) internal pure returns(string memory) {

        return string.concat(a, b);

    }

    function prepend(string memory a, string memory b) internal pure returns(string memory) {

        return string.concat(b, a);

    }

    function recover(string memory a, uint8 b, bytes32 c, bytes32 d) internal pure returns(address) {

        return ecrecover(keccak256(abi.encodePacked(keccak256(abi.encodePacked(a)))), b, c, d);

    }

}