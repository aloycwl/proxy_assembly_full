//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

contract TestCall {
    function getSelector(string memory s) external pure returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked(s)));
    }
}