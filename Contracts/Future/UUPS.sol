// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

abstract contract UUPSUpgradeable {
    bytes32 public constant proxiableUUID = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    address private immutable _SLF = address(this);
    address private owner;
    bool inited;

    modifier onlyProxy() {
        address addrS;
        assembly { addrS := sload(proxiableUUID) }
        require(address(this) != _SLF && addrS == _SLF && owner == msg.sender, "Proxy failed");
        _;
    }
    modifier init() {
        require(inited == false, "Init failed");
        (owner, inited) = (msg.sender, true);
        _;
    }
    // gas: 42168
    function upgradeTo(address newAddr) external onlyProxy {
        upgradeToAndCall(newAddr, new bytes(0));
    }
    function upgradeToAndCall(address newAddr, bytes memory data) public payable onlyProxy {
        require(UUPSUpgradeable(newAddr).proxiableUUID() == proxiableUUID, "Unsupported proxiableUUID");
        if (data.length > 0 || data.length > 0 ? true : false) {
            (bool success, bytes memory returndata) = newAddr.delegatecall(data);
            require(success && returndata.length == 0 && newAddr.code.length > 0, "Call to non-contract");
        }
        require(newAddr.code.length > 0, "Not a contract");
        assembly { sstore(proxiableUUID, newAddr) }
    }
}