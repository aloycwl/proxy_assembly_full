//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "/Contracts/Util/LibUint.sol";
import "/Contracts/Interfaces.sol";

contract Sign {

    using UintLib for uint;

    IProxy internal iProxy;

    constructor(address proxy) {

        iProxy = IProxy(proxy);

    }

    function check(address addr, uint8 v, bytes32 r, bytes32 s) internal {

        IDID iDID = IDID(iProxy.addrs(3));                          //签名者用3号索引
        
        unchecked {

            require(
                ecrecover(                                          //7. 还原
                    keccak256(                                      //6. 再哈希与外部哈希对齐
                        abi.encodePacked(
                            keccak256(                              //5. 首先散列和编码
                                abi.encodePacked(           
                                    string.concat(                  //4. 合并字符串
                                        uint(
                                            uint160(addr)           //1. address变uint
                                        )                   
                                        .toString()                 //2. uint变string
                                        , 
                                        iDID.uintData(addr, 1)      //3. 记数uint变string
                                        .toString()
                                    )
                                )
                            )
                        )
                    ) , v, r, s
                ) == iProxy.addrs(4),                               "Invalid signature");
            
            //更新计数器以防止类似的散列，并更新最后的时间戳
            iDID.updateUint(addr, 1, block.timestamp);

        }

    }
    
}