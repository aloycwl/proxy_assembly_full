//SPDX-License-Identifier:None
pragma solidity ^0.8.20;

//置对合约的访问
contract Util {
    mapping(address => uint) public access;
    //mapping(uint => address) private enumAccess;
    address[] private enumAccess;
    //uint private count = 1;

    constructor() {
        //(access[msg.sender], enumAccess[0]) = (1e3, msg.sender);
        access[msg.sender] = 1e3;
        enumAccess.push(msg.sender);
    }
    modifier OnlyAccess() {
        require(access[msg.sender] > 0, "Insufficient access");
        _;
    }
    //只可以管理权限币你小的人和授权比自己低的等级
    function setAccess(address addr, uint u) external OnlyAccess {
        unchecked{
            uint acc = access[msg.sender];
            require(acc > access[addr] && acc > u, "Invalid access");
            access[addr] = u;
            enumAccess.push(addr);
            //++count;
        }
    }
    //获取全部受权者及他们的等级
    function getAllAccessHolders() external view returns (address[] memory addrs, uint[] memory levels){
        unchecked{
            //(addrs, levels) = (new address[](count), new uint[](count));
            //for (uint i=0; i<count; i++) (addrs[i], levels[i]) = (enumAccess[i], access[enumAccess[i]]);
            uint count = enumAccess.length;
            levels = new uint[](count);
            for (uint i=0; i<count; i++) levels[i] = access[enumAccess[i]];
            addrs = enumAccess;
        }
    }
}