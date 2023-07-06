//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import {DID, Sign}     from "Contracts/Util/Sign.sol";
import {Access, ERC20} from "Contracts/ERC20.sol";

//游戏引擎
contract Engine is Access, Sign {

    uint  public  withdrawInterval = 60;  //以秒为单位的默认设置
    DID   private iDID;

    constructor(address did) Sign(did) {
        
        iDID = DID(did);

    }
    
    //利用签名人来哈希信息
    function withdraw(address addr, uint amt, uint8 v, bytes32 r, bytes32 s) external {

        unchecked {

            //确保账户不会被暂停、提款过早或签名错误
            require(iDID.uintData(address(0), addr, address(0)) == 0,       "User suspended");
            require(iDID.uintData(address(this), addr, 
                address(1)) + withdrawInterval < block.timestamp,           "Withdraw too soon");

            check(addr, v, r, s);                                           //检查签名和更新指数

            ERC20(iDID.addressData(address(0), 0, 2)).transfer(addr, amt);  //开始转移

        }

    }

    //设置取款间隔
    function setWithdrawInterval(uint _withdrawInterval) external OnlyAccess {

        withdrawInterval = _withdrawInterval;

    }

}