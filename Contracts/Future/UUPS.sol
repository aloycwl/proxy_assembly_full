// SPDX-License-Identifier: None
pragma solidity ^0.8.18;

abstract contract UUPSUpgradeable {
    bytes32 private constant _SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    address private immutable __self = address(this);
    address public owner;
    uint8 private _init;
    bool private _isInit;
    struct AddressSlot { address value; }

    modifier initializer() {
        bool isTLC = !_isInit;
        require((isTLC && _init < 1) || (!(address(this).code.length > 0) && _init == 1), "Already initialized");
        _init = 1;
        if (isTLC) _isInit = true;
        _;
        if (isTLC) _isInit = false;
    }
    modifier onlyProxy() {
        require(address(this) != __self && addrS(_SLOT).value == __self && owner == msg.sender, "Proxy failed");
        _;
    }

    function __Ownable_init() internal {
        require(_isInit, "Not initializing");
        owner = msg.sender;
    }
    function transferOwnership(address newOwner) external onlyProxy {
        owner = newOwner;
    }
    function addrS(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly { r.slot := slot }
    }

    function _upgradeUUPS(address newAddr, bytes memory data, bool forceCall) internal {
        require(UUPSUpgradeable(newAddr).proxiableUUID() == _SLOT, "Unsupported proxiableUUID");
        if (data.length > 0 || forceCall) {
            (bool success, bytes memory returndata) = newAddr.delegatecall(data);
            require(success && returndata.length == 0 && newAddr.code.length > 0, "Call to non-contract");
        }
        require(newAddr.code.length > 0, "Not a contract");
        addrS(_SLOT).value = newAddr;
    }
    function proxiableUUID() external view returns(bytes32) {
        require(address(this) == __self, "Cannot delegatecall");
        return _SLOT;
    }
    function upgradeTo(address newAddr) external onlyProxy {
        _upgradeUUPS(newAddr, new bytes(0), false);
    }
    function upgradeToAndCall(address newAddr, bytes memory data) external payable onlyProxy {
        _upgradeUUPS(newAddr, data, true);
    }
}