// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

abstract contract UUPSUpgradeable {
    bytes32 public constant UUID = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 private constant _OWN = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0;
    bytes32 private constant _INI = 0x9016906c42b25b8b9c5a4f8fb96df431241948aae1ac92547e2f35e14403c4d8;
    address private immutable _SLF = address(this);

    modifier onlyProxy() {
        address _slf = _SLF;
        assembly {
            // require(owner == msg.sender)
            if or(or(iszero(eq(caller(), sload(_OWN))),
                // require(addrS == _SLF)
                iszero(eq(sload(UUID), _slf))),
                // require(address(this) != _SLF)
                eq(address(), _slf)) {

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
            if sload(_INI) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x0b)
                mstore(0xC4, "Init failed")
                revert(0x80, 0x64)
            }
            // owner = msg.sender
            sstore(_OWN, caller())
            // inited = true;
            sstore(_INI, 0x1)
        }
    }

    function upgradeTo(address adr) external onlyProxy {
        upgradeToAndCall(adr, new bytes(0));
    }

    function upgradeToAndCall(address adr, bytes memory data) public onlyProxy {
        //require(UUPSUpgradeable(adr).UUID() == UUID, "Unsupported UUID");
        assembly {
            // UUPSUpgradeable(adr).UUID()
            mstore(0x80, 0x4c200b1000000000000000000000000000000000000000000000000000000000)
            pop(staticcall(gas(), adr, 0x80, 0x04, 0x00, 0x20))

            // require(UUPSUpgradeable(adr).UUID() == UUID)
            if iszero(eq(mload(0x0), UUID)) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x10)
                mstore(0xC4, "Unsupported UUID")
                revert(0x80, 0x64)
            }

            let dtl := mload(data)
            if gt(dtl, 0x00) {
                pop(delegatecall(gas(), adr, add(data, 0x20), dtl, 0x00, 0x00))
            }
            sstore(UUID, adr) 
        }
    }
}