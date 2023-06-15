//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "Contracts/Util/LibUint.sol";

contract Test {

    using LibUint for uint;

    mapping(address => uint) public uintData;

    function storeUint() external {
    

        uintData[0x0000000000000000000000000000000000000002] = 556;
    }

    function addition(uint x, uint y) public pure returns (uint) {
        
        assembly {
            
            
            mstore(0x0, add(x, y))
            
            return(0x0, 32)          
            
        }
    
    }
}

   /*function setUint(address addr, uint value) external {

        address t;

        assembly {
            // Load the address of the current contract into `m := 0x40`
            let m := mload(0x40)

            // Load the `msg.sender` value into `sender := 0x44`
            t := calldataload(44)
        }

            uintData[t] = value;

    }*/

//