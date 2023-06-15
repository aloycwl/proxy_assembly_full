//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "Contracts/Util/Access.sol";

//代理合同
contract Proxy is Access {

    mapping (uint => address) public addrs;

    constructor () {

        addrs[0] = address(this);

    }

    //动态设置要索引的地址
    function setAddr (address addr, uint index) external OnlyAccess () {

        addrs[index] = addr;

    }
    
}

/*
部署顺序：
1.  Proxy
2.  DID 
3.  Proxy setAddr(DID, 3)
4.  GameEngine
5.  DID setAccess() 授权到 GameEngine
6.  Proxy setAddr(GameEngine, 1)
7.  ERC20
8.  DID setAccess() 授权到 ERC20
9.  Proxy setAddr(ERC20, 2)
10. ERC721
11. DID setAccess() 授权到 ERC721
12. Proxy setAddr(ERC721, 5)
13. ERC20 mint() 铸币到 GameEngine
14. Proxy 加签名者 setAddr(signer, 4)
*/