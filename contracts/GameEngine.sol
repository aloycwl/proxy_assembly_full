//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Util.sol";

//游戏引擎
contract GameEngine is Access, Sign {

    IProxy private iProxy;
    uint public withdrawInterval = 60;  //以秒为单位的默认设置

    constructor(address proxy) Sign(proxy) {

        //调用交叉合约函数
        iProxy = IProxy(proxy);

    }
    
    //利用签名人来哈希信息
    function withdraw(address addr, uint amt, uint8 v, bytes32 r, bytes32 s) external {

        unchecked {

            IDID idid = IDID(iProxy.addrs(3));

            //确保账户不会被暂停、提款过早或签名错误
            require(idid.uintData(addr, 0) == 0, "Account is suspended");
            require(idid.uintData(addr, 2) + withdrawInterval < block.timestamp, "Withdraw too soon");

            //检查签名和更新指数
            check(addr, v, r, s);

            //开始转移
            IERC20(iProxy.addrs(2)).transfer(addr, amt);

        }
        
    }

    //设置取款间隔
    function setWithdrawInterval(uint _withdrawInterval) external OnlyAccess {

        withdrawInterval = _withdrawInterval;

    }

}