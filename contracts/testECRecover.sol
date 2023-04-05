// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VerifySignature {
    address public trustedSigner;

    constructor(address _trustedSigner) {
        trustedSigner = _trustedSigner;
    }

    function verify(string memory message, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(message));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        address recoveredSigner = ecrecover(ethSignedMessageHash, v, r, s);
        return (recoveredSigner == trustedSigner);
    }
}