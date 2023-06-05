//SPDX-License-Identifier:None
pragma solidity 0.8.18;

library Lib {

    //整数转移字符
    function uintToString(uint num) internal pure returns (string memory) {

        unchecked{

            //如果整数为 0，则不需要移位
            if (num == 0) return "0";                   
            uint j = num;
            uint l;

            //得到 10 的倍数的迭代
            while (j != 0) (++l, j /= 10);              

            //从整数创建单个数字
            bytes memory bstr = new bytes(l);           
            j = num;

            //遍历所有 10 的倍数，转换为单个整数而不是字节
            while (j != 0) (bstr[--l] = bytes1(uint8(48 + j % 10)), j /= 10);

            return string(bstr);

        }
    }
}