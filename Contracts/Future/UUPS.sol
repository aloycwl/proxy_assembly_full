// SPDX-License-Identifier: None
pragma solidity ^0.8.18;

// gas: 452331
abstract contract UUPSUpgradeable {
    bytes32 private constant _SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    address private immutable __self = address(this);
    address internal owner;
    struct AddrS { address value; }

    modifier onlyProxy() {
        require(address(this) != __self && addrS().value == __self && owner == msg.sender, "Proxy failed");
        _;
    }
    function __Ownable_init() internal {
        owner = msg.sender;
    }
    function transferOwner(address newOwner) external onlyProxy {
        owner = newOwner;
    }
    function addrS() internal pure returns (AddrS storage r) {
        assembly { r.slot := _SLOT }
    }
    function proxiableUUID() external view returns(bytes32) {
        require(address(this) == __self, "Cannot delegatecall");
        return _SLOT;
    }
    // gas: 42168
    function upgradeTo(address newAddr) external onlyProxy {
        upgradeToAndCall(newAddr, new bytes(0));
    }
    function upgradeToAndCall(address newAddr, bytes memory data) public payable onlyProxy {
        require(UUPSUpgradeable(newAddr).proxiableUUID() == _SLOT, "Unsupported proxiableUUID");
        if (data.length > 0 || data.length > 0 ? true : false) {
            (bool success, bytes memory returndata) = newAddr.delegatecall(data);
            require(success && returndata.length == 0 && newAddr.code.length > 0, "Call to non-contract");
        }
        require(newAddr.code.length > 0, "Not a contract");
        addrS().value = newAddr;
    }
}