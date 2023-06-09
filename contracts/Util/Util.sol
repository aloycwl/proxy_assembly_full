//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "../Lib.sol";
import "../Interfaces.sol";

//置对合约的访问
contract Access {

    mapping(address => uint) public access;

    //立即授予创建者访问权限
    constructor() {

        access[msg.sender] = 1e3;

    }

    //用作函数的修饰符
    modifier OnlyAccess() {

        require(access[msg.sender] > 0,             "Insufficient access");
        _;

    }

    //只可以管理权限币你小的人和授权比自己低的等级
    function setAccess(address addr, uint u) external OnlyAccess {

        unchecked{

            uint acc = access[msg.sender];

            //不能修改访问权限高于用户的地址和授予高于自己的访问权限
            require(acc > access[addr] && acc > u,  "Invalid access");

            access[addr] = u;

        }

    }
    
}

contract Sign {

    IProxy internal iProxy;

    constructor(address proxy) {

        iProxy = IProxy(proxy);

    }

    function check(address addr, uint8 v, bytes32 r, bytes32 s) internal {

        IDID iDID = IDID(iProxy.addrs(3));                          //签名者用3号索引
        
        unchecked {

            require(
                ecrecover(                                          //7. 还原
                    keccak256(                                      //6. 再散列和编码
                        abi.encodePacked(                           //   与外部哈希对齐
                            keccak256(                              //5. 首先散列和编码
                                abi.encodePacked(           
                                    string.concat(                  //4. 合并字符串
                                        Lib.uintToString(           //2. uint变string 
                                            uint(
                                                uint160(
                                                    addr            //1. address变uint
                                                )                   //   address变string
                                            )
                                        ), 
                                        Lib.uintToString(           //3. uint变string
                                            iDID.uintData(addr, 1)  //独特号码
                                        )
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