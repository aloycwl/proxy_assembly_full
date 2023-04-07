// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VerifySignature {
    address public trustedSigner;

    constructor(address _trustedSigner) {
        trustedSigner = _trustedSigner;
    }

    function verify(string memory message, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
        return (ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", 
            keccak256(abi.encodePacked(message)))), v, r, s) == trustedSigner);
            //select user latest counter
    }
}