pragma solidity>0.8.0;//SPDX-License-Identifier:None

contract myPractise {

    uint[] public arrayValue = [1, 2, 3, 4, 5, 6, 7];

    function pushArrayValue() public {  
        arrayValue.push(8);
    }
}