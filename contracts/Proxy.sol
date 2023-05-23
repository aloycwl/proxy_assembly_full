//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Util.sol";

//代理合同
contract Proxy is Util {

    mapping (uint => address) public addrs;

    //动态设置要索引的地址
    function setAddr(address addr, uint index) external OnlyAccess() {
        addrs[index] = addr;
    }
}