// SPDX-License-Identifier: None
pragma solidity 0.8.23;
pragma abicoder v1;

library Funcs {

    function TEST() external pure returns(bytes32) {
        assembly {
            mstore(0x00, shl(0x05, 0xd3Fa83260E4756b004Aaea2d3dE65CC99C27Ae0a))
            return(0x00, 0x20)
        }
    } 
    // 0x00000000000000000000001a7f5064c1c8ead600955d45a7bccb993384f5c140

    function conAdr2Hex(address a) external pure returns(bytes32) {
        assembly {
            mstore(0x00, a)
            return(0x00, 0x20)
        }
    }
    function conDec2Adr(uint a) external pure returns(address) {
        assembly {
            mstore(0x00, a)
            return(0x00, 0x20)
        }
    }
    function conDec2Hex(uint a) external pure returns (bytes memory b) {
        unchecked {
            uint len;
            for (uint i = a; i > 0; i /= 256) ++len;
            b = new bytes(len);
            for (uint i; i < len; ++i) b[len-i-1] = bytes1(uint8(a / (2**(8*i))));
        }
    }
    function conHex2Dec(bytes memory a) external pure returns(uint b) {
        unchecked{
            for(uint i; i < a.length; ++i) b += uint(uint8(a[i]))*(2**(8*(a.length-i-1)));
        }
    }
    function conHex2Str(bytes32 a) external pure returns(string memory) {
        assembly {
            mstore(0x80, 0x20)
            mstore(0xa0, 0x20)
            mstore(0xc0, a)
            return(0x80, 0x60)
        }
    }
    function conStr2Hex(string memory) external pure returns(bytes32) {
        assembly {
            return(0xa0, 0x20)
        }
    }
    function deploy(bytes memory a, uint b) external returns(address) {
        assembly{
            mstore(0x00, create2(callvalue(), add(a, 0x20), mload(a), b))
            return(0x00, 0x20)
        }
    }
    function getKeccak(uint a) external pure returns(bytes32) {
        assembly{
            mstore(0x00, a)
            mstore(0x00, keccak256(0x00, 0x20))
            return(0x00, 0x20)
        }
    }
    function getKeccak(bytes32 a) external pure returns(bytes32) {
        assembly{
            mstore(0x00, a)
            mstore(0x00, keccak256(0x00, 0x20))
            return(0x00, 0x20)
        }
    }
    function getKeccak(bytes32 a, bytes32 b) external pure returns(bytes32) {
        assembly{
            mstore(0x00, a)
            mstore(0x20, b)
            mstore(0x00, keccak256(0x00, 0x40))
            return(0x00, 0x20)
        }
    }
    function getSelect(string memory a) external pure returns(bytes4) {
        return bytes4(keccak256(abi.encodePacked(a)));
    }

    function getConAdr(bytes memory a, uint b) external view returns(address) {
        return address(uint160(uint(keccak256(abi.encodePacked(bytes1(0xff), address(this), b, keccak256(a))))));
    }
    function getConLen(address a) external view returns(uint) {
        return a.code.length;
    }

    function getECRvsr(bytes32 h, uint8 v, bytes32 r, bytes32 s) external pure returns(address) {
        return ecrecover(h, v, r, s);
    }
    function getECRvsr(bytes32 h, bytes memory c) external pure returns(address) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        assembly {
            r := mload(add(c, 0x20))
            s := mload(add(c, 0x40))
            v := byte(0, mload(add(c, 0x60)))
        }
        return ecrecover(h, v, r, s);
    }
    function getStrLen(string memory a) external pure returns(uint) {
        assembly {
            mstore(0x00, mload(a))
            return(0x00, 0x20)
        }
    }
}