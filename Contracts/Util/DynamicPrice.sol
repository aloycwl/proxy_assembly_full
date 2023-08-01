// SPDX-License-Identifier: None
pragma solidity ^0.8.19;
pragma abicoder v1;

contract DynamicPrice {

    constructor() {
        assembly {
            sstore(0xa, caller())
        }
    }

    function owner() external view returns (address a) {
        assembly {
            a := sload(0xa)
        }
    }

    function pay(address contAddr, uint _list, address to, uint fee) internal {
        assembly {
            // 索取List
            mstore(0x80, 0xdf0188db00000000000000000000000000000000000000000000000000000000) // listData(address,address,uint256)
            mstore(0x84, address())
            mstore(0xa4, contAddr)
            mstore(0xc4, _list)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x40))
            let tka := mload(0x0)
            let amt := mload(0x20)
            // 有价格才执行
            if gt(tka, 0x0) {
                fee := div(mul(amt, sub(0x2710, fee)), 0x2710)
                // 这是转加密货币
                if eq(tka, 0x1) {
                    // require(msg.value > amt)
                    if gt(amt, callvalue()) { 
                        mstore(0x80, shl(0xe5, 0x461bcd)) 
                        mstore(0x84, 0x20)
                        mstore(0xA4, 0x10)
                        mstore(0xC4, "Insufficient fee")
                        revert(0x80, 0x64)
                    }
                    pop(call(gas(), to, fee, 0x0, 0x0, 0x0, 0x0))
                    pop(call(gas(), sload(0x1), selfbalance(), 0x0, 0x0, 0x0, 0x0))
                }
                // 这是转ERC20代币
                if gt(tka, 0x1) {
                    // transferFrom(origin(), to, amt)
                    mstore(0x80, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
                    mstore(0x84, origin())
                    // require(transferForm(origin(), to, fee) = true)
                    mstore(0xa4, to)
                    mstore(0xc4, fee)    
                    if iszero(call(gas(), tka, 0x0, 0x80, 0x64, 0x0, 0x0)) {
                        mstore(0x80, shl(0xe5, 0x461bcd)) 
                        mstore(0x84, 0x20)
                        mstore(0xA4, 0x12)
                        mstore(0xC4, "Insufficient token")
                        revert(0x80, 0x64)
                    }
                    // require(transferForm(origin(), owner, fee) = true)
                    if gt(fee, 0x0) {
                        mstore(0xa4, sload(0x1))
                        mstore(0xc4, sub(amt, fee))
                        if iszero(call(gas(), tka, 0x0, 0x80, 0x64, 0x0, 0x0)) {
                            mstore(0x80, shl(0xe5, 0x461bcd)) 
                            mstore(0x84, 0x20)
                            mstore(0xA4, 0x12)
                            mstore(0xC4, "Insufficient token")
                            revert(0x80, 0x64)
                        }
                    }
                }
            }
        }
    }
}