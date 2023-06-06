//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Util.sol";

contract Test is Sign{

    constructor(address proxy) Sign(proxy) { }

    function see(address addr) public view returns (bytes32) {
            return keccak256(                              //6. 再散列和编码
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
                                            getCounter(addr)       //增量供以后使用
                                        )
                                    )
                                )
                            )
                        )
                    );
    }


    function see2(address addr) public view returns (bytes32) {
            return keccak256(                      //5. 首先散列和编码
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
                                            getCounter(addr)       //增量供以后使用
                                        )
                                    )
                                )
                           
                    );
    }

    function see3(address addr) public view returns (string memory) {
            return     
                                    string.concat(          //4. 合并字符串
                                        Lib.uintToString(   //2. uint变string 
                                            uint(
                                                uint160(
                                                    addr    //1. address变uint
                                                )           //   address变string
                                            )
                                        ), 
                                        Lib.uintToString(   //3. uint变string
                                            getCounter(addr)       //增量供以后使用
                                        )
                                    
                                
                           
                    );
    

    }
    function see5(address addr, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
       return  ecrecover(                                  //7. 还原
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
                                            getCounter(addr)       //增量供以后使用
                                        )
                                    )
                                )
                            )
                        )
                    ) , v, r, s) == getSigner();
    }

    function see6(address addr, uint8 v, bytes32 r, bytes32 s) public {
        check(addr, v, r, s);
    }
}