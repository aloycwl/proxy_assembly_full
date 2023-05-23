//SPDX-License-Identifier:None
pragma solidity ^0.8.20;

//被调用的接口
interface IERC20 {
    function transfer(address, uint) external returns (bool);
    function setAccess(address, uint) external;
}
interface IDID {
    function did(string calldata) external view returns (address);
    function uintData(address, uint) external view returns (uint);
    function updateDid(string calldata, address) external;
    function updateUint(address, uint, uint) external;
    function updateString(address, uint, string calldata) external;
    function setAccess(address, uint) external;
}
interface IProxy {
    function addrs(uint) external view returns (address);
    function setAddr(address, uint) external;
    function setAccess(address, uint) external;
}
interface IGameEngine {
    function setAccess(address, uint) external;
}