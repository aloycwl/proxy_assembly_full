//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

library LibUint {

    //整数转移字符
    function toString(uint a) internal pure returns (string memory) {

        unchecked {

            if(a == 0) return "0";

            uint l;

            for(uint j = a; j > 0; j /= 10) ++l;

            bytes memory bstr = new bytes(l);

            for(uint j = a; j > 0; j /= 10) bstr[--l] = bytes1(uint8(j % 10 + 48));

            return string(bstr);

        }
        
    }

}