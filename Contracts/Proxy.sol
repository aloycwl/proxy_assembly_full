//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Access} from "Contracts/Util/Access.sol";

//代理合同
contract Proxy is Access {

    mapping (uint => address) public addrs;

    constructor () {

        addrs[0] = address(this);

    }

    //动态设置要索引的地址
    function setAddr (address addr, uint index) external OnlyAccess () {

        addrs[index] = addr;

    }
    
}