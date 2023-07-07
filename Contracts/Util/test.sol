//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract test {

    function toString(uint a) external pure returns (string memory) {

        unchecked {

            if(a == 0x00) return "0";

            uint l;

            for(uint j = a; j > 0x00; j /= 0x0A) ++l;
                
            /*assembly {
                for { let j := a } sgt(j, 0) { j := div(j, 10) } {
                    l := add(l, 1)
                }
            }*/

            bytes memory bstr = new bytes(l);

            for(uint j = a; j > 0x00; j /= 0x0A) bstr[--l] = bytes1(uint8(j % 0x0A + 0x30));

            return string(bstr);

        }
        
    }

}