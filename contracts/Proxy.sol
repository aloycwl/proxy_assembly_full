//SPDX-License-Identifier:None
pragma solidity ^0.8.20;

import "./Util.sol";

//代理合同
contract Proxy is Util {
    mapping (uint => address) public addrs;

    function setAddr(address addr, uint index) external OnlyAccess() {
        addrs[index] = addr;
    }
}