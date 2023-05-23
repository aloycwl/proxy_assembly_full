//SPDX-License-Identifier:None
pragma solidity ^0.8.20;

library Lib {
    
    //整数转移字符
    function uintToString(uint num) internal pure returns (string memory) {
        unchecked{
            if (num == 0) return "0";
            uint j = num;
            uint l;
            while (j != 0) (++l, j /= 10);
            bytes memory bstr = new bytes(l);
            j = num;
            while (j != 0) (bstr[--l] = bytes1(uint8(48 + j % 10)), j /= 10);
            return string(bstr);
        }
    }
}