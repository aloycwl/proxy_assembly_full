//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract arraywy {

    /*function secondTest() public pure returns (uint[] memory res) {                                                                    
        assembly {                                                                                      
            res := mload(0x40)
            mstore(0x40, add(add(res, 0x20), 0x140))
            mstore(res, 10) 
        }                                                                         
    }    

    uint256[] public myArray;

    function pushTraditional(uint val) external {
        myArray.push(val);
    }

    function pushToArray(uint256 element) external {
        assembly {
            let length := sload(myArray.slot)

            sstore(myArray.slot, add(length, 1))

            let position := add(myArray.slot, mul(length, 32))

            sstore(position, element)

            sstore(myArray.slot, add(length, 1))
        }
    }*/

    //uint256[] public myArray;

    function pushar(uint val) external {
        assembly {
            let ptr := 0x0
            let len := sload(ptr)
            sstore(ptr, add(len, 1))
            mstore(0x0, ptr)
            sstore(add(keccak256(0x0, 0x20), mul(len, 0x1)), val)
        }
    }

    function getArray() external view returns (uint[] memory result) {

        uint len;
        
        assembly {
            let ptr := 0x0
            mstore(0x0, ptr)
            len := sload(ptr)
        }

        result = new uint[](len);

        assembly {
            mstore(result, len)
            let ptr := keccak256(0x0, 0x20)
            for { let i := 0x0 } lt(i, len) { i := add(i, 0x1) } {
                mstore(add(result, mul(add(i, 0x1), 0x20)), sload(add(ptr, i)))
            }
        }
    }
}