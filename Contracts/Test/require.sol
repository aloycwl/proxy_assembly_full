//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;


contract test1 {
    

    function test() external pure {
        assembly {
            //mstore(0x80, 0x08c379a000000000000000000000000000000000000000000000000000000000)
            mstore(0x80, shl(229, 4594637)) 
            mstore(0x84, 0x20) 
            mstore(0xA4, 0x2)
            mstore(0xC4, "05")
            revert(0x80, 0x64)
        }
    }

    /*error err(uint);

    function f() external pure {
        
        bytes4 errorSelector = err.selector;
        assembly {
            mstore(0, errorSelector)
            //mstore(0x0, 0x4c3f520d00000000000000000000000000000000000000000000000000000000)
            mstore(4, 0x10)
            revert(0, 0x24)
        }

        
    }

    function test() external pure {
        bool condition = false;
        bytes4 errorSelector = err.selector;
        assembly {
            if iszero(condition) {
                mstore(0, errorSelector)
                mstore(4, 0x3)
                revert(0, 0x24)
            }
        }
    }*/
}