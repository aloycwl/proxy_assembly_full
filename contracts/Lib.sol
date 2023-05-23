//SPDX-License-Identifier:None
pragma solidity ^0.8.20;

library Lib {

    //整数转移字符
    function uintToString(uint num) internal pure returns (string memory) {
        unchecked{
            if (num == 0) return "0";                   //如果整数为 0，则不需要移位
            uint j = num;
            uint l;
            while (j != 0) (++l, j /= 10);              //得到 10 的倍数的迭代
            bytes memory bstr = new bytes(l);           //从整数创建单个数字
            j = num;
            while (j != 0) (bstr[--l] =                 //遍历所有 10 的倍数
                bytes1(uint8(48 + j % 10)), j /= 10);   //转换为单个整数而不是字节
            return string(bstr);
        }
    }
}