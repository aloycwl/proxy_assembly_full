// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

abstract contract UUPSUpgradeable {
    bytes32 public constant UUID = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 private constant owner = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0;
    bytes32 private constant inited = 0x9016906c42b25b8b9c5a4f8fb96df431241948aae1ac92547e2f35e14403c4d8;
    address private immutable _SLF = address(this);
    //bool inited;

    modifier onlyProxy() {
        address _slf = _SLF;
        assembly {
            // require(owner == msg.sender)
            if or(or(iszero(eq(caller(), sload(owner))),
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
            if sload(inited) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20) 
                mstore(0xA4, 0x0b)
                mstore(0xC4, "Init failed")
                revert(0x80, 0x64)
            }
            // owner = msg.sender
            sstore(owner, caller())
            // inited = true;
            sstore(inited, 0x1)
        }
    }

    // gas: 42168
    function upgradeTo(address newAddr) external onlyProxy {
        upgradeToAndCall(newAddr, new bytes(0));
    }
    function upgradeToAndCall(address newAddr, bytes memory data) public onlyProxy {
        require(UUPSUpgradeable(newAddr).UUID() == UUID, "Unsupported proxiableUUID");
        if (data.length > 0 || data.length > 0 ? true : false) {
            (bool success, bytes memory returndata) = newAddr.delegatecall(data);
            require(success && returndata.length == 0 && newAddr.code.length > 0, "Call to non-contract");
        }
        require(newAddr.code.length > 0, "Not a contract");
        assembly { sstore(UUID, newAddr) }
    }
}