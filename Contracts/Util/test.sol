//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract test {

    constructor() {
        assembly{
            sstore(0x0, origin())
        }
    }

    function owner() external view returns (address) {

        assembly {
            mstore(0x0, sload(0x0))
            return(0x0, 0x20)
        }

    }

    function yes() external pure returns (uint) {

        assembly {
            mstore(0x0, 0x55)
            return(0x0, 0x20)
        }

    }


    function toString(uint a) external pure returns (string memory) {

        unchecked {

            //if(a == 0x00) return "0";

            assembly {
                if eq(a, 0x00) {
                    
                    mstore8(0x0, 0x68)
                    return(mload(0x0), 0x20)

                }
            }

            uint l;

            for(uint j = a; j > 0x00; j /= 0x0A) ++l;
                
            /*assembly {
                for { let j := a } sgt(j, 0) { j := div(j, 10) } {
                    l := add(l, 1)
                }
            }*/

            /*bytes memory bstr = new bytes(l);

            for(uint j = a; j > 0x00; j /= 0x0A) bstr[--l] = bytes1(uint8(j % 0x0A + 0x30));

            return string(bstr);*/

            assembly {
                // Set the memory location for the bytes array
                let bstr := mload(0x40)
                // Store the length of the bytes array
                mstore(bstr, l)

                for {let j := a} gt(j, 0x00) { j := div(j, 0x0A) } {
                    // Calculate j % 0x0A
                    let remainder := mod(j, 0x0A)

                    // Calculate the index for the bytes array
                    let index := sub(l, 1)

                    // Store the ASCII representation of the remainder in the bytes array
                    mstore8(add(bstr, index), add(remainder, 0x30))

                    // Decrement the loop counter l
                    l := sub(l, 1)
                }

                // Set the bytes array as the return value
                return(bstr, l)
            }

        }
        
    }

}