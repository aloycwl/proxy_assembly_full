/***
需要DID授权
先部署这合约，拿此地址再过去DID合约setAccess
***/

//SPDX-License-Identifier:None
pragma solidity ^0.8.20;

import "./Util.sol";
import "./Interfaces.sol";

contract DIDFunctions is Util {
    IDID idid;

    modifier OnlyUnique(string calldata userName) {
        require(idid.did(userName) == address(0), "Username existed");
        _;
    }

    constructor(address did){
        idid = IDID(did);
    }

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
}