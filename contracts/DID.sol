pragma solidity 0.8.20;//SPDX-License-Identifier:None

//置对合约的访问
contract Util {
    
    mapping(address => uint) public access;

    modifier OnlyAccess() {
        require(access[msg.sender] > 0, "Insufficient access");
        _;
    }
    function setAccess(address addr, uint u) public OnlyAccess {
        require(access[msg.sender] > access[addr], "Unable to modify address with higher access");
        require(access[msg.sender] > u, "Access level has to be lower than grantor");
        access[addr] = u;
    }
}

contract DID is Util{
    address private _owner;
    uint private _count;
    string private _did;
    mapping (string => uint) did; //if did existed, value = count
    mapping (uint => mapping (uint => string)) public stringData;
    mapping (uint => mapping (uint => address)) public addressData;
    mapping (uint => mapping (uint => uint)) public uintData;

    modifier UniqueOnly(string calldata _username) {
        require(did[_username] == 0, "Username existed");
        _;
    }

    constructor() {
       access[address(this)] = access[msg.sender] = 999;
    }

    function createUser(address _addr, string calldata _username, string calldata _name, string calldata _bio) 
        external UniqueOnly(_username) {
        unchecked{
            did[_username] = ++_count;
            updateString(_count, 0, _username);
            updateString(_count, 1, _name);
            updateString(_count, 2, _bio);
            updateAddress(_count, 0, _addr);
        }
    }

    function changeUsername(string calldata _strBefore, string calldata _strAfter) external UniqueOnly(_strAfter) {
        require(msg.sender == addressData[did[_strBefore]][0], "Only owner can change user name");
        updateString(_count, 0, _strAfter);
    }

    function updateString(uint _id, uint _index, string calldata _str) public OnlyAccess {
        stringData[_id][_index] = _str;
    }

    function updateAddress(uint _id, uint _index, address _addr) public OnlyAccess {
        addressData[_id][_index] = _addr;
    }

    function updateUint(uint _id, uint _index, uint _uint) public OnlyAccess {
        uintData[_id][_index] = _uint;
    }
}