// SPDX-License-Identifier: None
pragma solidity ^0.8.18;

interface IERC1822 {
    function proxiableUUID() external view returns(bytes32);
}

abstract contract UUPSUpgradeable is IERC1822 {
    bytes32 internal constant _SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    address private immutable __self = address(this);
    address private _owner;
    uint8 private _initialized;
    bool private _initializing;
    struct AddressSlot { 
        address value; 
    }

    modifier initializer() {
        bool isTLC = !_initializing;
        require((isTLC && _initialized < 1) || (!isContract(address(this)) && _initialized == 1), "Already initialized");
        _initialized = 1;
        if (isTLC) _initializing = true;
        _;
        if (isTLC) _initializing = false;
    }
    modifier onlyInitializing() {
        require(_initializing, "Not initializing");
        _;
    }
    modifier onlyProxy() {
        require(address(this) != __self, "Through delegatecall");
        require(getAddressSlot(_SLOT).value == __self, "Not active proxy");
        require(_owner == msg.sender, "Not the owner");
        _;
    }

    function owner() external view returns(address) {
        return _owner;
    }
    function __Ownable_init() internal onlyInitializing {
        _owner = msg.sender;
    }
    function renounceOwnership() external onlyProxy {
        _owner = address(0);
    }
    function transferOwnership(address newOwner) external onlyProxy {
        _owner = newOwner;
    }
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly { r.slot := slot }
    }

    function _upgradeUUPS(address newImplementation, bytes memory data, bool forceCall) internal {
        try IERC1822(newImplementation).proxiableUUID() returns (bytes32 slot) {
            require(slot == _SLOT, "Unsupported proxiableUUID");
        } catch {
            revert("Not UUPS");
        }
        if (data.length > 0 || forceCall) {
            (bool success, bytes memory returndata) = newImplementation.delegatecall(data);
            if (success) {
                if (returndata.length == 0) require(isContract(newImplementation), "Call to non-contract");
            } else 
                if (returndata.length > 0)
                    assembly {
                        let returndata_size := mload(returndata)
                        revert(add(32, returndata), returndata_size)
                    }
                else revert("Call to non-contract");
        }
        require(isContract(newImplementation), "Not a contract");
        getAddressSlot(_SLOT).value = newImplementation;
    }
    function proxiableUUID() external view returns(bytes32) {
        require(address(this) == __self, "Cannot delegatecall");
        return _SLOT;
    }
    function upgradeTo(address newImplementation) external onlyProxy {
        _upgradeUUPS(newImplementation, new bytes(0), false);
    }
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable onlyProxy {
        _upgradeUUPS(newImplementation, data, true);
    }
}