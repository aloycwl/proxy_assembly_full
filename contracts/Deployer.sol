//SPDX-License-Identifier:None
pragma solidity 0.8.20;

import "./GameEngine.sol";

//专注部署合约
contract Deployer {
    function deployAll(string memory name, string memory symbol) external returns (address proxy) {
        address did = deployDID();
        proxy = deployProxyPlus(did, name, symbol);
    }
    function deployProxyPlus(address did, string memory name, string memory symbol) public returns (address proxy) {
        proxy = deployProxy();
        address gameEngine = deployGameEngine(proxy);
        address erc20 = deployERC20(proxy, gameEngine, 1e27, name, symbol);

        IProxy iProxy = IProxy(proxy);
        iProxy.setAddr(gameEngine, 0);
        iProxy.setAddr(address(erc20), 1);
        iProxy.setAddr(did, 2);
        iProxy.setAddr(msg.sender, 3); //signer
    }
    function deployProxy() public returns (address proxy) {
        proxy = address(new Proxy(msg.sender));
        setDeployment(proxy, "Proxy");
    }
    function deployDID() public returns (address did) {
        did = address(new DID(msg.sender));
        setDeployment(did, "DID");
    }
    function deployGameEngine(address proxy) public returns (address gameEngine) {
        gameEngine = address(new GameEngine(msg.sender, proxy));
        setDeployment(gameEngine, "Game Engine");
    }
    function deployERC20(address proxy, address receiver, uint amt, string memory name, string memory symbol) 
        public returns (address erc20) {
        erc20 = address(new ERC20(msg.sender, proxy, receiver, amt, name, symbol));
        setDeployment(erc20, "ERC20");
    }
    //设置和索取部署资料
    address[] private enumAddresses;
    string[] private enumFunctions;
    function setDeployment(address addr, string memory func) private {
        enumAddresses.push(addr);
        enumFunctions.push(func);
    }
    function getAllDeployments() external view returns (address[] memory addresses, string[] memory functions){
        unchecked{
            uint count = enumAddresses.length;
            (addresses, functions) = (new address[](count), new string[](count));
            for (uint i=0; i<count; i++) (addresses[i], functions[i]) = (enumAddresses[i], enumFunctions[i]);
        }
    }
}
