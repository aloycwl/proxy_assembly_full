pragma solidity 0.8.20;//SPDX-License-Identifier:None

contract TestECDSA{

    address signer = 0xA34357486224151dDfDB291E13194995c22Df505;

    function u2s(uint num) private pure returns (string memory) {
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

    function testString(address addr, uint index, uint8 v, bytes32 r, bytes32 s) 
        public view returns(bool){
        
        return ecrecover(keccak256(abi.encodePacked(
            keccak256(abi.encodePacked(string.concat(
                u2s(uint(uint160(addr))), u2s(index)))))), v, r, s)
                    == signer;
    }

}