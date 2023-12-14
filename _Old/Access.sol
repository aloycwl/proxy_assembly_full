// SPDX-License-Identifier: None
pragma solidity 0.8.18;
pragma abicoder v1;

contract Access {

    bytes32 constant internal ACC = 0xba820cc3887163b837a8768e6a5b186b16a86bdf66a4448502c551f31328f85f;
    bytes32 constant internal ERR = 0x08c379a000000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal ER1 = 0x6e6f206163636573730000000000000000000000000000000000000000000000; // "no access"
    bytes32 constant internal ER2 = 0x6e6f206163636573730000000000000000000000000000000000000000000000; // "no approval"

    constructor() {
        assembly {
            mstore(0x00, ACC)
            mstore(0x20, caller())
            sstore(keccak256(0x00, 0x40), 0xff)
        }
    }

    modifier onlyAccess() {
        assembly {
            mstore(0x00, ACC)
            mstore(0x20, caller())
            if iszero(sload(keccak256(0x00, 0x40))) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x09)
                mstore(0xC4, ER1)
                revert(0x80, 0x64)
            }
        }
        _;
    }

    function setMem(bytes32 byt, bytes32 val) external onlyAccess {
        assembly {
            sstore(byt, val)
        }
    }

    function getMem(bytes32 byt) external view returns(bytes32) {
        assembly {
            mstore(0x00, sload(byt))
            return(0x00, 0x20)
        }
    }
}
