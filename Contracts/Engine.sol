//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Access}      from "Contracts/Util/Access.sol";
import {Sign, Proxy} from "Contracts/Util/Sign.sol";
import {ERC20, DID}  from "Contracts/ERC20.sol";

//游戏引擎
contract Engine is Access, Sign {

    uint    public  withdrawInterval = 60;  //以秒为单位的默认设置
    Proxy   private iProxy;

    constructor (address proxy) Sign (proxy) {
        
        iProxy = Proxy(proxy);

    }
    
    //利用签名人来哈希信息
    function withdraw (address addr, uint amt, uint8 v, bytes32 r, bytes32 s) external {

        unchecked {

            //确保账户不会被暂停、提款过早或签名错误
            DID idid = DID(iProxy.addrs(3));
            require(idid.uintData(address(0), addr, address(0)) == 0,               "Account is suspended");
            require(idid.uintData(address(this), addr, 
                address(1)) + withdrawInterval < block.timestamp,                   "Withdraw too soon");

            check(addr, v, r, s);                           //检查签名和更新指数

            ERC20(iProxy.addrs(2)).transfer(addr, amt);     //开始转移

        }
        
    }

    //设置取款间隔
    function setWithdrawInterval (uint _withdrawInterval) external OnlyAccess {

        withdrawInterval = _withdrawInterval;

    }

}