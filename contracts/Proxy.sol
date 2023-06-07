//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./DID.sol";
import "./GameEngine.sol";
import "./ERC20.sol";

//代理合同
contract Proxy is Access {

    mapping(uint => address) public addrs;

    constructor() {

        addrs[0] = address(this);

    }

    //动态设置要索引的地址
    function setAddr(address addr, uint index) external OnlyAccess() {

        addrs[index] = addr;

    }
    
}

contract DeployDID is Access {

    function deployDID(address proxyAddr) external {

        address addr = address(new DID());
        Access(addr).setAccess(msg.sender,          999);
        Proxy(proxyAddr).setAddr(addr,              3);

    }

    function addAccessDID(address proxyAddr) external {
        
        Proxy proxy = Proxy(proxyAddr);
        Access iAccess = Access(proxy.addrs(3));
        iAccess.setAccess(proxy.addrs(1),           900);       //需要授权来提币
        iAccess.setAccess(proxy.addrs(2),           900);       //用于储存
        iAccess.setAccess(proxy.addrs(5),           900);       //用于储存

    }

}

contract DeployGameEngine is Access {

    function deployGameEngine(address proxyAddr) external {

        address addr = address(new GameEngine(proxyAddr));
        Access(addr).setAccess(msg.sender,          999);
        Proxy(proxyAddr).setAddr(addr,              1);

    }
    
}

 
contract DeployERC20 is Access {

    function deployGameEngine(address proxyAddr, string calldata name, string calldata symbol) external {

        address addr = address(new ERC20(proxyAddr, name, symbol));
        Access(addr).setAccess(msg.sender,          999);
        Proxy(proxyAddr).setAddr(addr,              2);

    }
    
}