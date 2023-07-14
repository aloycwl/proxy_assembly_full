//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;


contract test1 {
    

    function test() external pure {
        assembly {
            function x() {
                mstore(0x80, shl(229, 4594637)) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x2)
            }
            x()
            mstore(0xC4, "05")
            revert(0x80, 0x64)
        }
    }

    function test2(address from) external view returns (uint val) {
        assembly {
            val := xor(eq(from, caller()), 0)
            /*if eq(from, caller()) {
                mstore(0x80, shl(229, 4594637)) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x2)
                mstore(0xC4, "0A")
                revert(0x80, 0x64)
            }*/
        }
    }

}