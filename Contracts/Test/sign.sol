//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract Sign {

    function test() external pure returns(address) {

        uint8 v = 28;
        bytes32 r = 0x95451769cc5fbf8c02cd3b08f3336b3c56a742b9871d16e68be51a73cd246677;
        bytes32 s = 0x76ef0859dca3627f1d73a5bae195d8c088e2b03243a4fa5bd2b0b9c93a1def88;

        address addr = 0xA34357486224151dDfDB291E13194995c22Df505;
        uint counter = 1688453994;

        bytes32 hash;

        assembly {
            mstore(0x00, add(addr, counter))
            mstore(0x00, keccak256(0x00, 0x20))
            hash := keccak256(0x00, 0x20)
        }

        return ecrecover(hash, v, r, s);

    }

}