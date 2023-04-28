// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Sign {
    
    function genMsg(
        uint256 num,
        uint256[] memory list,
        address _address
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(num, list, _address));
    }

    function check(
        uint256 num,
        uint256[] memory list,
        address _address,
        bytes memory sig
    ) public pure returns (address) {
        return recoverSigner(genMsg(num,list,_address),sig);
    }
    
    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }
}
