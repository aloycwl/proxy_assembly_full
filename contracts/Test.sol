//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Util.sol";

contract Test{

    function see(address addr, uint index) public pure returns (bytes32) {
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
                                            index       //增量供以后使用
                                        )
                                    )
                                )
                            )
                        )
                    );
    }


    function see2(address addr, uint index) public pure returns (bytes32) {
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
                                            index       //增量供以后使用
                                        )
                                    )
                                )
                           
                    );
    }

    function see3(address addr, uint index) public pure returns (string memory) {
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
                                            index       //增量供以后使用
                                        )
                                    
                                
                           
                    );
    

    }
}