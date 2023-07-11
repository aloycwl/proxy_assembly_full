//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract Sign {

    function test() external pure returns(address) {

        uint8 v = 28;
        bytes32 r = 0x520c3ab3717abce7439b675837f11a8fc5a29949d4de0296d69a5b3d2b6a67c3;
        bytes32 s = 0x12516f02fb9fc134651d19e976c375c1d498a20588ee9d8313a30b2646ba590b;
            
        address addr = 0xA34357486224151dDfDB291E13194995c22Df505;
        uint counter = 1689037672;

        bytes32 hash;

        assembly {
            mstore(0x0, add(addr, counter))
            mstore(0x0, keccak256(0x0, 0x20))
            hash := keccak256(0x0, 0x20)
        }

        return ecrecover(hash, v, r, s);
        

    }
}