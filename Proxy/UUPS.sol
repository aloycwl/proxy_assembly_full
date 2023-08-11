// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

abstract contract UUPSUpgradeable {
    bytes32 constant public UUID = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 constant private OWN = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0;
    bytes32 constant private INI = 0x9016906c42b25b8b9c5a4f8fb96df431241948aae1ac92547e2f35e14403c4d8;
    bytes32 constant private UUI = 0x5cc99e3500000000000000000000000000000000000000000000000000000000;
    bytes32 constant private ERR = 0x08c379a000000000000000000000000000000000000000000000000000000000;
    address private immutable SLF = address(this);

    modifier onlyProxy() {
        address slf = SLF;
        assembly {
            // require(owner == msg.sender && addrS == _SLF && address(this) != _SLF)
            if or(or(iszero(eq(caller(), sload(OWN))), iszero(eq(sload(UUID), slf))), eq(address(), slf)) {
                mstore(0x80, ERR) 
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
                mstore(0x80, ERR) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x0a)
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
            if iszero(eq(mload(0x00), UUID)) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x0a)
                mstore(0xC4, "UUID failed")
                revert(0x80, 0x64)
            }
            
            sstore(UUID, adr) 
        }
    }
}