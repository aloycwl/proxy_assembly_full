// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

contract CommonFunctions {
    function getSelector(string memory a) external pure returns(bytes4) {
        return bytes4(keccak256(abi.encodePacked(a)));
    }

    function getKeccak256(string memory a) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(a));
    }

    function getContractLength(address a) external view returns(uint) {
        return a.code.length;
    }

    /*function getBytecode() external pure returns (bytes memory) {
        return type(TestCreationCode).creationCode;
    }*/

    function getDeployAdr(bytes memory a, uint b)public view returns (address) {
        return address(uint160(uint(keccak256(abi.encodePacked(bytes1(0xff), address(this), b, keccak256(a))))));
    }

    function deploy(bytes memory a, uint b) external payable returns(address) {
        assembly{
            mstore(0x00, create2(callvalue(), add(a, 0x20), mload(a), b))
            return(0x00, 0x20)
        }
    }

    function convertHex2Dec(bytes memory a) external pure returns(uint b) {
        for(uint i = 0; i < a.length; ++i) b += uint(uint8(a[i]))*(2**(8*(a.length-i-1)));
    }

    function convertDec2Hex(uint a) external pure returns (bytes memory b) {
        uint len;
        for (uint i = a; i > 0; i /= 256) ++len;
        b = new bytes(len);
        for (uint i = 0; i < len; ++i) b[len-i-1] = bytes1(uint8(a / (2**(8*i))));
    }

    function convertStr2Hex(string memory a) external pure returns(bytes32) {
        assembly {
            mstore(0x00, mload(add(a, 0x20)))
            return(0x00, 0x20)
        }
    }

    function convertDec2Adr(uint a) external pure returns(address) {
        assembly {
            mstore(0x00, a)
            return(0x00, 0x20)
        }
    }

    function recover(bytes32 h, bytes memory c) external pure returns(address) {
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

    function recover(bytes32 h, uint8 v, bytes32 r, bytes32 s) external pure returns(address) {
        return ecrecover(h, v, r, s);
    }
}

/*contract TestCreationCode {
    uint public constant storedNumber = 0x0500;
}*/