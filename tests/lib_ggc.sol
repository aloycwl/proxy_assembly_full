// SPDX-License-Identifier:None
pragma solidity 0.8.23;
pragma abicoder v1;

import {Assert} from "remix_tests.sol";
import {Proxy} from "../Proxy.sol";
import {GGC} from "../GameAsset/GGC.sol";
    
library Z {
    bytes32 constant public OWO = 0x6352211e00000000000000000000000000000000000000000000000000000000;
    address constant public AC7 = 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7;

    string constant public E02 = "contract should not be 0";
    string constant public E03 = "name should not be empty";
    string constant public E04 = "symbol should not be empty";
    string constant public E05 = "decimals should be 18";
    string constant public E06 = "totalSupply should be 0 before mint";
    string constant public E07 = "balance of contract should be 0";
    string constant public E08 = "balance of contract should be 1e20";
    string constant public E09 = "allowance should be 1e19";
    string constant public E10 = "balance of user 7 should be 0";
    string constant public E11 = "balance of user 7 should be 1e18";
    string constant public E12 = "allowance should be 9e18";
    string constant public E13 = "balance of user 7 should be 1e19";
    string constant public E14 = "balance of contract should be 9e19";
    string constant public E15 = "allowance should still be 9e18";
    string constant public E16 = "balance of user 7 should be 2e19";
    string constant public E17 = "total supply should be 11e19";
    string constant public E18 = "owner should be this contract";
    string constant public E19 = "owner should changed to user";
    string constant public E21 = "should throw error";
    string constant public E22 = "balance of contract should be 8e19";
    string constant public E23 = "balance of AC7 should be 2e19";
    string constant public E24 = "balance of contract should be 7e19";
    string constant public E25 = "balance of AC7 should be 3e19";

    function toBytes32(address a) public pure returns (bytes32) {
        return bytes32(uint(uint160(a)));
    }

    function toBytes32(uint a) public pure returns (bytes32) {
        return bytes32(a);
    }
}