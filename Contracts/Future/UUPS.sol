// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

abstract contract UUPSUpgradeable {
    bytes32 public constant UID = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 private constant OWN = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0;
    bytes32 private constant INI = 0x9016906c42b25b8b9c5a4f8fb96df431241948aae1ac92547e2f35e14403c4d8;
    bytes32 private constant UUI = 0x5c0b0f9600000000000000000000000000000000000000000000000000000000;
    address private immutable SLF = address(this);

    modifier onlyProxy() {
        address slf = SLF;
        assembly {
            // require(owner == msg.sender)
            if or(or(iszero(eq(caller(), sload(OWN))),
                // require(addrS == _SLF)
                iszero(eq(sload(UID), slf))),
                // require(address(this) != _SLF)
                eq(address(), slf)) {

                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x0c)
                mstore(0xC4, "Proxy failed")
                revert(0x80, 0x64)
            }
        }
        _;
    }

    function init() internal {
        assembly {
            // require(inited == false)
            if sload(INI) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x0b)
                mstore(0xC4, "Init failed")
                revert(0x80, 0x64)
            }
            // owner = msg.sender
            sstore(OWN, caller())
            // inited = true;
            sstore(INI, 0x01)
        }
    }

    function upgradeTo(address adr) external onlyProxy {
        //upgradeToAndCall(adr, new bytes(0));
        assembly {
            // UUPSUpgradeable(adr).UUID()
            mstore(0x80, UUI)
            pop(staticcall(gas(), adr, 0x80, 0x04, 0x00, 0x20))

            // require(UUPSUpgradeable(adr).UUID() == UUID)
            if iszero(eq(mload(0x00), UID)) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x0b)
                mstore(0xC4, "UUID failed")
                revert(0x80, 0x64)
            }
            
            sstore(UID, adr) 
        }
    }
}