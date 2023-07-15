//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

contract TEST  {


    function uintEnum() external pure returns (uint[] memory val) {


        //val = new uint[](1);
        //val[0] = 99;

        assembly {
            mstore(val, 0x1)
            mstore(add(val, 0x20), 0x1)
            mstore(add(val, 0x40), 0x64)
            mstore(add(val, 0x60), 0x1)
            mstore(add(val, 0x80), 0x63)
            mstore(0xc0, 0x60)
        }

 
    }

    
}