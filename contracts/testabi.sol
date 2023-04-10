pragma solidity 0.8.19;//SPDX-License-Identifier:None

contract TTTT{
    address private signer=0xA34357486224151dDfDB291E13194995c22Df505;

    function u2s(uint a) public pure returns (string memory) {
        if (a == 0) return "0";
        uint j = a;
        uint l;
        while (j != 0) (++l, j /= 10);
        bytes memory bstr = new bytes(l);
        j = a;
        while (j != 0) (bstr[--l] = bytes1(uint8(48 + j % 10)), j /= 10);
        return string(bstr);
    }

    function testU(address addr, uint c, uint8 v, bytes32 r, bytes32 s) external view returns(bool) {
        unchecked {
            return (ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", 
                keccak256(abi.encodePacked(u2s(uint(uint160(addr))), u2s(c))))), v, r, s) == signer);
            
        }
    }

    function test(address addr, uint num) external pure returns(bytes32){
        return keccak256(abi.encodePacked(u2s(uint(uint160(addr))), u2s(num)));
    }
} 