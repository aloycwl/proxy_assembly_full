// SPDX-License-Identifier: None
pragma solidity ^0.8.18;

interface IERC1822ProxiableUpgradeable {
    function proxiableUUID() external view returns(bytes32);
}

interface IBeaconUpgradeable {
    function implementation() external view returns(address);
}

library LibU {
    struct AddressSlot { 
        address value; 
    }
    struct BooleanSlot { 
        bool value; 
    }
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly { r.slot := slot }
    }
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly { r.slot := slot }
    }
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        if (success) {
            if (returndata.length == 0) require(isContract(target), "Address: call to non-contract");
            return returndata;
        } else 
            if (returndata.length > 0)
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
            else revert("Address: call to non-contract");
    }
}

abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require((isTopLevelCall && _initialized < 1) || (!LibU.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized");
        _initialized = 1;
        if (isTopLevelCall) _initializing = true;
        _;
        if (isTopLevelCall) _initializing = false;
    }
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
}

abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable {
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    address private immutable __self = address(this);
    address private _owner;

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    function owner() external view returns(address){
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

    function _getImplementation() internal view returns (address) {
        return LibU.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }
    function _setImplementation(address newImplementation) private {
        require(LibU.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        LibU.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) LibU.functionDelegateCall(newImplementation, data);
    }
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall) internal {
        if (LibU.getBooleanSlot(0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143).value) 
            _setImplementation(newImplementation);
        else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }
    
    
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }
    function upgradeTo(address newImplementation) external onlyProxy {
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable onlyProxy {
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }
}