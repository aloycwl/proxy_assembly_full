//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Lib.sol";
import "./Util.sol";
import "./Interfaces.sol";
import "./Sign.sol";

//游戏引擎
contract GameEngine is Util, Sign {
    IProxy private iProxy;
    uint public withdrawInterval = 60;  //以秒为单位的默认设置

    constructor(address proxy) {
        //调用交叉合约函数
        iProxy = IProxy(proxy);
    }
    
    //利用签名人来哈希信息
    function withdraw(address addr, uint amt, uint8 v, bytes32 r, bytes32 s) external {
        unchecked {
            IDID idid = IDID(iProxy.addrs(3));
            uint counter = idid.uintData(addr, 1);

            //确保账户不会被暂停、提款过早或签名错误
            require(idid.uintData(addr, 0) == 0, "Account is suspended");
            require(idid.uintData(addr, 2) + withdrawInterval < block.timestamp, "Withdraw too soon");
            require(
                ecrecover(                                  //7. 还原
                    keccak256(                              //6. 再散列和编码
                        abi.encodePacked(                   //   与外部哈希对齐
                            keccak256(                      //5. 首先散列和编码
                                abi.encodePacked(           
                                    string.concat(          //4. 合并字符串
                                        Lib.uintToString(   //2. uint变string 
                                            uint(
                                                uint160(
                                                    addr    //1. address变uint
                                                )           //   address变string
                                            )
                                        ), 
                                        Lib.uintToString(   //3. uint变string
                                            counter
                                        )
                                    )
                                )
                            )
                        )
                    ) , v, r, s
                ) == iProxy.addrs(4), "Invalid signature");

            //更新计数器以防止类似的散列，并更新最后的时间戳
            idid.updateUint(addr, 1, counter + 1);
            idid.updateUint(addr, 2, block.timestamp);

            //开始转移
            IERC20(iProxy.addrs(2)).transfer(addr, amt);
        }
    }

    //设置取款间隔
    function setWithdrawInterval(uint _withdrawInterval) external OnlyAccess {
        withdrawInterval = _withdrawInterval;
    }
}