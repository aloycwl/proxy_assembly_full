//SPDX-License-Identifier:None
pragma solidity ^0.8.20;

import "./Lib.sol";
import "./Util.sol";
import "./Interfaces.sol";

//游戏引擎
contract GameEngine is Util {
    IProxy private iProxy;
    uint public withdrawInterval = 60;

    constructor(address proxy) {
        iProxy = IProxy(proxy);
    }
    
    //利用签名人来哈希信息
    function withdraw(address addr, uint amt, uint8 v, bytes32 r, bytes32 s) external {
        unchecked {
            IDID idid = IDID(iProxy.addrs(3));
            uint counter = idid.uintData(addr, 1);

            require(idid.uintData(addr, 0) == 0, "Account is suspended");
            require(idid.uintData(addr, 2) + withdrawInterval < block.timestamp, "Withdraw too soon");
            require(
                ecrecover(                                  //7. 还原
                    keccak256(                              //6. 再散列和编码
                        abi.encodePacked(                   //   与外部哈希对齐
                            keccak256(                      //5. 首先散列和编码
                                abi.encodePacked(           
                                    string.concat(          //4. 合并字符串
                                        Lib.uintToString(   //2. uint => string 
                                            uint(
                                                uint160(
                                                    addr    //1. address => uint
                                                )           //   address ≠> string
                                            )
                                        ), 
                                        Lib.uintToString(   //3. uint => string
                                            counter
                                        )
                                    )
                                )
                            )
                        )
                    ) , v, r, s
                ) == iProxy.addrs(4), "Invalid signature");

            idid.updateUint(addr, 1, counter + 1);
            idid.updateUint(addr, 2, block.timestamp);

            IERC20(iProxy.addrs(2)).transfer(addr, amt);
        }
    }
    //管理功能
    function setWithdrawInterval(uint _withdrawInterval) external OnlyAccess {
        withdrawInterval = _withdrawInterval;
    }
}