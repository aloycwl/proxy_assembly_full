//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Util.sol";

//代理合同
contract Proxy is IProxy, Access {

    mapping(uint => address) public addrs;

    constructor() {

        addrs[0] = address(this);

    }

    //动态设置要索引的地址
    function setAddr(address addr, uint index) external OnlyAccess() {

        addrs[index] = addr;

    }
    
}

/*
部署顺序：
1.  Proxy
2.  DID 
3.  Proxy setAddr(DID, 3)
4.  GameEngine
5.  Proxy setAddr(GameEngine, 1)
6.  ERC20
7.  Proxy setAddr(ERC20, 2)
8.  ERC721
9.  Proxy setAddr(ERC721, 5)
10. ERC20 mint() 铸币到 GameEngine
11. DID setAccess() 授权到 GameEngine
12. DID setAccess() 授权到 ERC20
13. DID setAccess() 授权到 ERC721
14. Proxy 加签名者 setAddr(signer, 4)
*/