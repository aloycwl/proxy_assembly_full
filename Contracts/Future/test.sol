// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

contract no {

    bytes32 public constant proxiableUUID = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    address private immutable _SLF = address(this);
    struct AddrS { address value; }

    function addrS() private pure returns (AddrS storage r) {
        assembly { r.slot := proxiableUUID }
    }
    function value() external view returns (address val) {
        return addrS().value;
    }

    //49862/26977
    function slotTest1() external {
        assembly {
            sstore(0x5, 0x55)
        }
    }

    //49837/26952
    function slotTest2() external {
        assembly {
            sstore(0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0, 0x55)
        }
    }
}