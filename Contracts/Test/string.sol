//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

library LibUint {

    function toString(uint a) internal pure returns (string memory) {

        assembly {
                
            let l

            mstore(0x40, 0x20)
            mstore(0x60, 0x20)

            if iszero(a) {
                mstore8(0x80, 0x30)
            }

            for { let j := a } gt(j, 0) { j := div(j, 10) } {
                l := add(l, 1)
            }

            for { } gt(a, 0) { a := div(a, 0xA) } {
                l := sub(l, 0x1)
                mstore8(add(0x80, l), add(mod(a, 0xA), 0x30))
            }

            return(0x40, 0x60)

        }

    }

}