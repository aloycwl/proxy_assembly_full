//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Access, DID} from "Contracts/DID.sol";

contract DIDFunctions is Access {

    DID iDID;

    //用户名不能重复
    modifier OnlyUnique(string calldata userName) {

        require(iDID.did(userName) == address(0), "Username existed");
        _;

    }

    constructor(address did) {

        //调用主合约
        iDID = DID(did);

    }

    //谁都可以创造新用户
    function createUser(address addr, string calldata userName, string calldata name, string calldata bio) 
        external OnlyUnique(userName) {

            iDID.did(userName, addr);             //创建用户名
            iDID.stringData(addr, 0, userName);       //能够从地址中找到用户名
            iDID.stringData(addr, 1, name);           //添加名称
            iDID.stringData(addr, 2, bio);            //添加传记

    }

    //改用户名，删除旧名来省燃料
    function changeUsername(string calldata before, string calldata aft) external OnlyUnique(aft) {

        address addr = iDID.did(before);

        assert(msg.sender == addr);                     //只有所有者可以更改他们的用户名
        
        iDID.did(before, address(0));             //删除旧用户名
        iDID.did(aft, addr);                      //添加新用户名
        iDID.stringData(addr, 0, aft);                //更新地址搜索

    }
    
}