//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract test {

    bytes32 public constant positionone = keccak256("bar");
    bytes32 public constant positiontwo = keccak256("pos");
    
    constructor() {
        string memory bar = "some strings";
        bytes32 _positionone = positionone;
        bytes32 _positiontwo = positiontwo;
        assembly {
            sstore(_positionone, mload(bar)) // length
            sstore(_positiontwo, mload(add(bar, 0x20))) // value
        }
    }

    function boo() public view returns (string memory p) {
        bytes32 _positionone = positionone;
        bytes32 _positiontwo = positiontwo;
        assembly {
            p := mload(0x40)
            mstore(p, sload(_positionone))
            mstore(add(p, 0x20), sload(_positiontwo))
            // set the pointer to free memory
            mstore(0x40, add(p, 0x40))
        }
    }

    function yes() external pure returns (string memory str) {

        return "hahaha";

        string memory a = "somestring";

        /*assembly {
            p := mload(0x40)
            mstore(p, mload(a))
            mstore(add(p, 0x20), mload(add(a, 0x20)))
            mstore(0x40, add(p, 0x40))
        }*/

    }


    function toString(uint a) external pure returns (string memory) {

        unchecked {

            //if(a == 0x00) return "0";

            assembly {
                if eq(a, 0x00) {
                    
                    let p := mload(0x40)
                    mstore(p, 0x68)
                    return(p, 0x20)

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