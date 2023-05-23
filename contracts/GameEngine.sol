//SPDX-License-Identifier:None
pragma solidity ^0.8.20;

import "./Lib.sol";
import "./Util.sol";
import "./Interfaces.sol";

//游戏引擎
contract GameEngine is Util {
    IProxy private iProxy;
    uint public withdrawInterval = 60;

    constructor(address proxy) Util() {
        iProxy = IProxy(proxy);
    }
    
    //利用签名人来哈希信息
    function withdraw(address addr, uint amt, uint8 v, bytes32 r, bytes32 s) external {
        unchecked {
            require(IDID(iProxy.addrs(3)).uintData(addr, 0) == 0, "Account is suspended");
            require(IDID(iProxy.addrs(3)).uintData(addr, 2) + withdrawInterval < block.timestamp, "Withdraw too soon");
            require(ecrecover(keccak256(abi.encodePacked(keccak256(abi.encodePacked(string.concat(
                Lib.u2s(uint(uint160(addr))), Lib.u2s(IDID(iProxy.addrs(3)).uintData(addr, 1))))))), v, r, s) 
                == iProxy.addrs(4), "Invalid signature");

            IDID(iProxy.addrs(3)).updateUint(addr, 1, IDID(iProxy.addrs(3)).uintData(addr, 1) + 1);
            IDID(iProxy.addrs(3)).updateUint(addr, 2, block.timestamp);

            IERC20(iProxy.addrs(2)).transfer(addr, amt);
        }
    }
    //管理功能
    function setWithdrawInterval(uint _withdrawInterval) external OnlyAccess {
        withdrawInterval = _withdrawInterval;
    }
}