//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract arraywy {

    function secondTest() public pure returns (uint[] memory res) {                                                                    
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
            // Load the length of the array
            let length := sload(myArray.slot)

            // Resize the array by increasing the length
            sstore(myArray.slot, add(length, 1))

            // Calculate the position to store the new element
            let position := add(myArray.slot, mul(length, 32))

            // Store the element at the calculated position
            sstore(position, element)

            sstore(myArray.slot, add(length, 1))
        }
    }

    function getValueAtIndex(uint256 index) external view returns (uint value) {
        assembly {
            // Load the length of the array
            let length := sload(myArray.slot)

            // Check if the index is within bounds
            if iszero(lt(index, length)) {
                revert(0, 0)
            }

            // Calculate the position of the desired element
            let position := add(myArray.slot, add(mul(add(index, 1), 32), 32))

            // Load the value at the calculated position
            value := sload(position)
        }
    }
}