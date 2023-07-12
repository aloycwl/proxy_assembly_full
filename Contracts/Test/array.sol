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
}