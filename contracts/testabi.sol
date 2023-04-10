pragma solidity 0.8.4;//SPDX-License-Identifier:None

contract TTTT{
    address private signer=0x2b89c69bC7bAACe9862a0F1f862F4b8ce5A6aB4d;

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
    function testU(address a, uint c, uint8 v, bytes32 r, bytes32 s) external view returns(bool) {
        unchecked {
            return (ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", 
                keccak256(abi.encodePacked(a,"/",u2s(c))))), v, r, s) == signer);
            
        }
    }



    function test() external view returns(bytes32){
        return keccak256(abi.encodePacked(u2s(uint(uint160(msg.sender))), "/", u2s(501)));
    }
    function test2() external view returns(bytes32){
        return keccak256(abi.encodePacked(msg.sender, "/", u2s(501)));
    }
} 