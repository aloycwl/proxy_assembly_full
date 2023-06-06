//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Util.sol";

//储存和去中心化身份合约
contract DID is Access {

    mapping (string => address) public did;
    mapping (address => mapping (uint => string)) public stringData;
    mapping (address => mapping (uint => address)) public addressData;
    mapping (address => mapping (uint => uint)) public uintData;
    
    //持有权限者才能更新数据
    function updateDid(string calldata str, address addr) external OnlyAccess {

        did[str] = addr;

    }

    function updateString(address addr, uint index, string calldata val) external OnlyAccess {

        stringData[addr][index] = val;

    }

    function updateAddress(address addr, uint index, address val) external OnlyAccess {

        addressData[addr][index] = val;

    }

    function updateUint(address addr, uint index, uint val) external OnlyAccess {

        uintData[addr][index] = val;

    }
    
}