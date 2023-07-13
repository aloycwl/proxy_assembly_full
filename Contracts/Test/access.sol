//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;


contract test1 {
    

    function test() external pure {
        assembly {
            mstore(0x80, shl(229, 4594637)) 
            mstore(0x84, 32) 
            mstore(0xA4, 30)
            mstore(0xC4, "Amount to raise smaller than 0")
            revert(0x80, 0x64)
        }
        //require(false, "0x04");
    }
}