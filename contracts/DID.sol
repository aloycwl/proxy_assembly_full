//SPDX-License-Identifier:None
pragma solidity ^0.8.20;

import "./Util.sol";

//储存和去中心化身份合约
contract DID is Util {
    mapping (string => address) did;
    mapping (address => mapping (uint => string)) public stringData;
    mapping (address => mapping (uint => address)) public addressData;
    mapping (address => mapping (uint => uint)) public uintData;

    modifier OnlyUnique(string calldata userName) {
        require(did[userName] == address(0), "Username existed");
        _;
    }
    
    constructor() Util() { }
    //谁都可以创造新用户
    function createUser(address addr, string calldata userName, string calldata name, string calldata bio) 
        external OnlyUnique(userName) {
            (did[userName], stringData[addr][0]) = (addr, userName);
            stringData[addr][1] = name;
            stringData[addr][2] = bio;
    }
    //改用户名，删除旧名来省燃料
    function changeUsername(string calldata strBefore, string calldata strAfter) external OnlyUnique(strAfter) {
        address addr = did[strBefore];
        require(msg.sender == addr, "Invalid owner");
        delete did[strBefore];
        updateString(did[strAfter] = addr, 0, strAfter);
    }
    //持有权限者才能更新数据
    function updateString(address addr, uint index, string calldata val) public OnlyAccess {
        stringData[addr][index] = val;
    }
    function updateAddress(address addr, uint index, address val) public OnlyAccess {
        addressData[addr][index] = val;
    }
    function updateUint(address addr, uint index, uint val) public OnlyAccess {
        uintData[addr][index] = val;
    }
}