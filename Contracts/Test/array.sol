//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract arraywy {

    function secondTest() public pure returns (uint32[] memory res) {                                                                    
        assembly {                                                                                      
            res := mload(0x40)
            mstore(0x40, add(add(res, 0x20), 640))
            mstore(res, 20) 
        }                                                                         
    }    
}