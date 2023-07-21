// SPDX-License-Identifier: None
// solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

contract TESTING {
    function mv() external view returns(address val) { // 0x8f05cdf5
        val = msg.sender;
    }

    function mv2() external view returns(address val) { // 0xc2b17a06
        assembly {
            val := caller()
        }
    }

    function mv3() external view returns(address val) { // 0x003be508
        assembly {
            val := origin()
        }
    }
}


contract TESTING2 {
    address addr;

    constructor(address a) {
        addr = a;
    }

    function TTT() external view returns(bytes32 val) {
        assembly {
            val := sload(addr.slot)
        }
    }

    function mv10() external view returns(address val) {
        val = TESTING(addr).mv();
    }
    
    function mv11() external view returns(address val) {
        assembly {
            mstore(0x80, shl(0xe0, 0x8f05cdf5))
            pop(staticcall(gas(), sload(addr.slot), 0x80, 0x4, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function mv20() external view returns(address val) {
        val = TESTING(addr).mv2();
    }

    function mv21() external view returns(address val) {
        assembly {
            mstore(0x80, shl(0xe0, 0xc2b17a06))
            pop(staticcall(gas(), sload(addr.slot), 0x80, 0x4, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function mv30() external view returns(address val) {
        val = TESTING(addr).mv3();
    }

    function mv31() external view returns(address val) {
        assembly {
            mstore(0x80, shl(0xe0, 0x003be508))
            pop(staticcall(gas(), sload(addr.slot), 0x80, 0x4, 0x0, 0x20))
            val := mload(0x0)
        }
    }
}