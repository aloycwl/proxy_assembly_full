//SPDX-License-Identifier:None
pragma solidity ^0.8.0;

import "Contracts/Util/Access.sol";

//代理合同
contract Proxy is Access {
    
}

/*
部署顺序：
Proxy
Proxy   => setAddr      (signer,    4)
DID 
Proxy   => setAddr      (DID,       3)
Engine
Proxy   => setAddr      (Engine,    1)
DID     => setAccess    (Engine,    100)
ERC20
Proxy   => setAddr      (ERC20,     2)
DID     => setAccess    (ERC20,     100)
ERC20   => mint         (Engine,    10000000000000000000000000000000000000000)
ERC721
Proxy   => setAddr      (ERC721,    5)
DID     => setAccess    (ERC721,    100) 
Market
DID     => setAccess    (Market,    100) 
*/