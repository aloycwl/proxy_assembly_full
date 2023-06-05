//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Lib.sol";
import "./Interfaces.sol";

contract Sign {

    IProxy private iProxy;

    constructor(address proxy) {

        iProxy = IProxy(proxy);

    }

    function check(address addr, uint8 v, bytes32 r, bytes32 s) internal {

        IDID iDID = IDID(iProxy.addrs(3));                  //签名者用3号索引
        uint counter = iDID.uintData(addr, 1);
        
        unchecked {

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
                                            ++counter       //增量供以后使用
                                        )
                                    )
                                )
                            )
                        )
                    ) , v, r, s
                ) == iProxy.addrs(4), "Invalid signature");
            
            //更新计数器以防止类似的散列，并更新最后的时间戳
            iDID.updateUint(addr, 1, counter);
            iDID.updateUint(addr, 2, block.timestamp);

        }

    }
    
}