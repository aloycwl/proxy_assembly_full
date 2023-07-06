//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract test {

    function toString(uint a) external pure returns (string memory) {

        unchecked {

            //如果整数为 0，则不需要移位
            if(a == 0) return "0";                   
            uint j;
            uint l;

            //得到 10 的倍数的迭代
            //while (j != 0) (++l, j /= 10);
            for(j = a; j > 0; j /= 10) ++l;
                
            /*assembly {
                for { j := a } sgt(j, 0) { j := div(j, 10) } {
                    l := add(l, 1)
                }
            }*/

            //从整数创建单个数字
            bytes memory bstr = new bytes(l);

            //遍历所有 10 的倍数，转换为单个整数而不是字节
            for(j = a; j > 0; j /= 10) bstr[--l] = bytes1(uint8(48 + j % 10));

            return string(bstr);

        }
        
    }

}