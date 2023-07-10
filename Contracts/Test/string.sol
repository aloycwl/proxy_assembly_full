//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

library LibUint {

    function toString(uint a) internal pure returns (string memory) {

        unchecked{

            assembly {
                
                let str := mload(0x40)
                let l

                mstore(str, 0x20)
                mstore(add(str, 0x20), 0x20)

                if iszero(a) {
                    mstore(add(str, 0x40), 0x30)
                }

                for { let j := a } gt(j, 0) { j := div(j, 10) } {
                    l := add(l, 1)
                }

                for { 
                    let j := a 
                } gt(j, 0) { 
                    j := div(j, 0xA) 
                    l := sub(l, 0x1)
                } {
                    mstore8(add(str, add(0x40, l)), add(mod(j, 0xA), 0x30))

                }

                return(str, 0x60)
            }

        }

    }

}