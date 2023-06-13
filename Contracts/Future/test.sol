//SPDX-License-Identifier:None
pragma solidity 0.8.18;

contract Test {

    mapping(address => uint) uintData;

    /*function storeUint(address addr, uint value) external {
        assembly {
            // Store the uint value in the mapping
            sstore(add(uintData.slot, addr), value)
        }
    }*/

    function setUint(address addr, uint value) external {

        uintData[addr] = value;

    }

    function getUint(address addr) external view returns (uint) {
        return uintData[addr];
    }

}

//