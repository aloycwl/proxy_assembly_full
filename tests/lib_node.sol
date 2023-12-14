// SPDX-License-Identifier:None
pragma solidity 0.8.23;
pragma abicoder v1;

import {Assert} from "remix_tests.sol";
import {Proxy} from "../Proxy.sol";
import {Node} from "../Governance/Node.sol";
import {GGC} from "../GameAsset/GGC.sol";
import {Item} from "../GameAsset/Item.sol";
    
library Z {

    bytes32 constant public TTF = 0xa9059cbb00000000000000000000000000000000000000000000000000000000;
    bytes32 constant public TP5 = 0x2fea05d400000000000000000000000000000000000000000000000000000000;
    bytes32 constant public APP = 0x095ea7b300000000000000000000000000000000000000000000000000000000;
    bytes32 constant public R = 0x5568b5565151508fac71ad34cb981e6f3b4e9f0fa75732af4c686a34a0625bbc;
    bytes32 constant public S = 0x05c363be1f2d552fe17c4cd9df805d14a1b35268d0298b9f2d25a9f689c745a4;

    address constant public AC7 = 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7;
    address constant public ADM = 0xA34357486224151dDfDB291E13194995c22Df505;

    string constant public E02 = "contract should not be 0";
    string constant public E03 = "address should be sender";
    string constant public E04 = "status should be 2";
    string constant public E05 = "withdrawal amount should be 1e20";
    string constant public E06 = "withdrawal address to should be AC7";
    string constant public E07 = "status should be 0";
    string constant public E08 = "contract balance should be 1e18";
    string constant public E09 = "game should be added and return true";
    string constant public E10 = "node balance should be 995e17";
    string constant public E11 = "msg sender should be in top 5";
    string constant public E12 = "status should be more than 0";
    string constant public E13 = "should throw error";
    string constant public E14 = "game should be removed and return false";
    string constant public E15 = "contract balance should be 1e20";

    function toUint(address a) public pure returns (uint) {
        return uint(uint160(a));
    }

    function toBytes32(address a) public pure returns (bytes32) {
        return bytes32(toUint(a));
    }

    function toBytes32(uint a) public pure returns (bytes32) {
        return bytes32(a);
    }

    function fmtIndex(uint a, uint b) public pure returns(bytes32) {
        assembly {
            mstore(0x00, a)
            mstore(0x00, add(keccak256(0x00, 0x20), b))
            return(0x00, 0x20)
        }
    }

    function fmtVote(address a) public pure returns(bytes32) {
        assembly {
            mstore(0x00, a)
            mstore8(0x00, 0x01)
            return(0x00, 0x20)
        }
    }

}