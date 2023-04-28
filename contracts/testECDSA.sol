pragma solidity 0.8.19;//SPDX-License-Identifier:None

contract TestECDSA{

    event LogS(string);
    event LogB(bytes32);

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

    function withdraw(address addr, uint index, uint v, bytes32 r, bytes32 s) external view returns(bool) {

        return ecrecover(
            keccak256(abi.encodePacked(u2s(uint(uint160(addr))), u2s(index))), uint8(v), r, s) == signer ?
            true : false;
    
    }

    function withdraw2(bytes32 h, uint8 v, bytes32 r, bytes32 s) public pure 
        returns (address) {
        
        return ecrecover(keccak256(abi.encodePacked(h)), v, r, s);
    }

    function testKeccak(string memory str) public pure returns(bytes32){
        return keccak256(abi.encodePacked(str));
    }


    function testString(address addr, uint index, uint8 v, bytes32 r, bytes32 s) 
        public returns(address){

            //string memory s1 = string.concat(u2s(uint(uint160(addr))), u2s(index));
            string memory s1 = "haha";
            emit LogS(s1);
            bytes32 b1 = keccak256(abi.encodePacked(s1));
            emit LogB(b1);
        
        return ecrecover(b1, v, r, s);
    }

}