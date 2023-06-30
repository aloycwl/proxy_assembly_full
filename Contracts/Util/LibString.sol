//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

library LibString {

    function append(string memory a, string memory b) internal pure returns(string memory) {

        return string.concat(a, b);

    }

    function prepend(string memory a, string memory b) internal pure returns(string memory) {

        return string.concat(b, a);

    }

}