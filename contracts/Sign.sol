//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Lib.sol";
import "./Interfaces.sol";

contract Sign{
    function check(address proxy, address addr, uint8 v, bytes32 r, bytes32 s) external view {
        IProxy iProxy = IProxy(proxy);
        IDID idid = IDID(iProxy.addrs(3));
        uint counter = idid.uintData(addr, 1);

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
    }
}