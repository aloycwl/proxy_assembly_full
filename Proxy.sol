// ERC-897: DelegateProxy
// SPDX-License-Identifier: None
pragma solidity 0.8.23;
pragma abicoder v1;

import {Ownable} from "../Util/Ownable.sol";

contract Proxy is Ownable {
    
    address private imp;

    constructor(address adr) {
        assembly {
            sstore(IN2, adr) // implementation = adr;
        }
    }

    fallback() external payable {
        assembly {
            calldatacopy(0x00, 0x00, calldatasize())
            let res := delegatecall(gas(), sload(IN2), 0x00, calldatasize(), 0x00, 0x00)
            let sze := returndatasize()
            returndatacopy(0x00, 0x00, sze)
            switch res
            case 0 { revert(0x00, sze) }
            default { return(0x00, sze) }
        }
    }

    receive() external payable {
        assembly {
            calldatacopy(0x00, 0x00, calldatasize())
            let res := delegatecall(gas(), sload(IN2), 0x00, calldatasize(), 0x00, 0x00)
            let sze := returndatasize()
            returndatacopy(0x00, 0x00, sze)
            switch res
            case 0 { revert(0x00, sze) }
            default { return(0x00, sze) }
        }
    }

    function implementation() external view returns(address) {
        assembly {
            mstore(0x00, sload(IN2))
            return(0x00, 0x20)
        }
    }

    function mem(bytes32 byt) external view returns(bytes32) {
        assembly {
            mstore(0x00, sload(byt))
            return(0x00, 0x20)
        }
    }

    function mem(bytes32 byt, bytes32 val) external onlyOwner {
        assembly {
            sstore(byt, val)
        }
    }
}