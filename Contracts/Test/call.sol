//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

contract TestCall {

    function getSelector(string memory s) external pure returns (bytes4) {
        return bytes4(keccak256(abi.encodePacked(s)));
    }

    function TESTshl() external pure returns(uint256 val){
        assembly {
            //val := 0x1000000000000000000000000000000000000000
            val := shl(0x9c, 0x1)
        }
    }
}