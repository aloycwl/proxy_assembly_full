/***
需要DID授权
先部署这合约，拿此地址再过去DID合约setAccess
***/

//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "Contracts/Util/Access.sol";
import "Contracts/DID.sol";

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

            iDID.updateDid(userName, addr);             //创建用户名
            iDID.updateString(addr, 0, 0, userName);    //能够从地址中找到用户名
            iDID.updateString(addr, 1, 0, name);        //添加名称
            iDID.updateString(addr, 2, 0, bio);         //添加传记

    }

    //改用户名，删除旧名来省燃料
    function changeUsername(string calldata strBefore, string calldata strAfter) external OnlyUnique(strAfter) {

        address addr = iDID.did(strBefore);

        assert(msg.sender == addr);                     //只有所有者可以更改他们的用户名
        
        iDID.updateDid(strBefore, address(0));          //删除旧用户名
        iDID.updateDid(strAfter, addr);                 //添加新用户名
        iDID.updateString(addr, 0, 0, strAfter);        //更新地址搜索

    }
    
}