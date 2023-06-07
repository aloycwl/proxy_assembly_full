//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./DID.sol";

//代理合同
contract Proxy is Access {

    mapping(uint => address) public addrs;

    //动态设置要索引的地址
    function setAddr(address addr, uint index) external OnlyAccess() {

        addrs[index] = addr;

    }
    
}

contract DeployDID is Access {

    function deployDID(address proxyContractAddress) external {

        address addr = address(new DID());
        Access(addr).setAccess(msg.sender,          999);
        Proxy(proxyContractAddress).setAddr(addr, 3);

    }

    function addAccessDID(address proxyContractAddress) external {
        
        Proxy proxy = Proxy(proxyContractAddress);
        Access iAccess = Access(proxy.addrs(3));
        iAccess.setAccess(proxy.addrs(1),           900);       //需要授权来提币
        iAccess.setAccess(proxy.addrs(2),           900);       //用于储存
        iAccess.setAccess(proxy.addrs(5),           900);       //用于储存

    }

}
 
