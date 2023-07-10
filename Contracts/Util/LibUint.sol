//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

library LibUint {

    //整数转移字符
    function toString(uint a) internal pure returns (string memory) {

        assembly {
                
            let l

            mstore(0x20, 0x20)
            mstore(0x40, 0x20)

            if iszero(a) {
                mstore8(0x60, 0x30)
            }

            for { let j := a } gt(j, 0x0) { j := div(j, 0xa) } {
                l := add(l, 0x1)
            }

            for { } gt(a, 0x0) { a := div(a, 0xa) } {
                l := sub(l, 0x1)
                mstore8(add(l, 0x60), add(mod(a, 0xa), 0x30))
            }

            return(0x20, 0x60)

        }
        
    }

}