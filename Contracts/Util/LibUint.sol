//SPDX-License-Identifier:None
pragma solidity 0.8.18;

library LibUint {

    //整数转移字符
    function toString(uint a) internal pure returns (string memory) {

        unchecked {

            //如果整数为 0，则不需要移位
            if (a == 0) return "0";                   
            uint j = a;
            uint l;

            //得到 10 的倍数的迭代
            while (j != 0) (++l, j /= 10);              

            //从整数创建单个数字
            bytes memory bstr = new bytes(l);           
            j = a;

            //遍历所有 10 的倍数，转换为单个整数而不是字节
            while (j != 0) (bstr[--l] = bytes1(uint8(48 + j % 10)), j /= 10);

            return string(bstr);

        }
    }

    //将费用转换为百分比, xx.xx
    function minusPercent(uint a, uint b) internal pure returns (uint) {

        unchecked {

            return a * (1e4 - b) / 1e4;
        }

    }

}