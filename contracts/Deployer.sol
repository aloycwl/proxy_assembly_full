//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Proxy.sol";
import "./GameEngine.sol";
import "./ERC20.sol";
import "./ERC721.sol";
import "./DID.sol";
import "./Interfaces.sol";

//专注部署合约
contract Deployer {

    function deployAll(string calldata name, string calldata symbol) external returns (address proxy) {

        address did = deployDID();
        proxy = deployProxyPlus(did, name, symbol);

    }

    function deployProxyPlus(address did, string memory name, string memory symbol) public returns (address proxy) {

        proxy = deployProxy();
        address gameEngine = deployGameEngine(proxy);
        address erc20 = deployERC20(proxy, name, symbol);
        address erc721 = deployERC721(proxy, name, symbol);
        setDeployment(msg.sender, "[4 - signer]");

        IProxy iProxy = IProxy(proxy);
        iProxy.setAddr(proxy,               0);
        iProxy.setAddr(gameEngine,          1);
        iProxy.setAddr(erc20,               2);
        iProxy.setAddr(did,                 3);
        iProxy.setAddr(msg.sender,          4);         //签名人
        iProxy.setAddr(erc721,              5);
        IUtil(did).setAccess(gameEngine,    900);       //需要授权来提币
        IUtil(did).setAccess(erc20,         900);       //用于储存
        IUtil(did).setAccess(erc721,        900);       //用于储存

        //ERC20(erc20).mint(gameEngine, 1e27);            //铸币

    }

    function deployProxy() public returns (address addr) {

        addr = address(new Proxy());
        IUtil(addr).setAccess(msg.sender, 999);
        setDeployment(addr, "[0 - Proxy]");

    }

    function deployGameEngine(address proxy) public returns (address addr) {

        addr = address(new GameEngine(proxy));
        IUtil(addr).setAccess(msg.sender, 999);
        setDeployment(addr, "[1 - Game Engine]");

    }

    function deployERC20(address proxy, string memory name, string memory symbol) 
        public returns (address addr) {

        addr = address(new ERC20(proxy, name, symbol));
        IUtil(addr).setAccess(msg.sender, 999);
        setDeployment(addr, "[2 - ERC20]");

    }

    function deployDID() public returns (address addr) {

        addr = address(new DID());
        IUtil(addr).setAccess(msg.sender, 999);
        setDeployment(addr, "[3 - DID]");

    }

    function deployERC721(address proxy, string memory name, string memory symbol) 
        public returns (address addr) {

        addr = address(new ERC721(proxy, name, symbol));
        IUtil(addr).setAccess(msg.sender, 999);
        setDeployment(addr, "[5 - ERC721]");

    }

    //设置和索取部署资料
    address[] private enumAddresses;
    string[] private enumFunctions;

    function setDeployment(address addr, string memory func) private {

        enumAddresses.push(addr);
        enumFunctions.push(func);

    }

    function getAllDeployments() external view returns (address[] memory addresses, string[] memory functions) {

        unchecked{

            uint count = enumAddresses.length;
            (addresses, functions) = (new address[](count), new string[](count));
            for (uint i=0; i<count; i++) (addresses[i], functions[i]) = (enumAddresses[i], enumFunctions[i]);

        }

    }
    
}
