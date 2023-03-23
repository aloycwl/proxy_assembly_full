pragma solidity 0.8.19;//SPDX-License-Identifier:None

contract WDUtil{
    function GetKeccak(string memory a)external pure returns(bytes32){
        return keccak256(abi.encodePacked(a));
    }
}