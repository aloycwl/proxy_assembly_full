// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

contract DynamicPrice {

    bytes32 constant private LID = 0xdf0188db00000000000000000000000000000000000000000000000000000000;
    bytes32 constant private TTF = 0x23b872dd00000000000000000000000000000000000000000000000000000000;

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

    function pay(address adr, uint lst, address toa, uint fee) internal {
        assembly {
            // 索取List
            mstore(0x80, LID) // listData(address,address,uint256)
            mstore(0x84, address())
            mstore(0xa4, adr)
            mstore(0xc4, lst)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x00, 0x40))
            let tka := mload(0x00)
            let amt := mload(0x20)
            // 有价格才执行
            if gt(tka, 0x00) {
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
                    pop(call(gas(), toa, fee, 0x00, 0x00, 0x00, 0x00))
                    pop(call(gas(), sload(0x01), selfbalance(), 0x00, 0x00, 0x00, 0x00))
                }
                // 这是转ERC20代币
                if gt(tka, 0x01) {
                    // transferFrom(origin(), to, amt)
                    mstore(0x80, TTF)
                    mstore(0x84, origin())
                    // require(transferForm(origin(), to, fee) = true)
                    mstore(0xa4, toa)
                    mstore(0xc4, fee)    
                    if iszero(call(gas(), tka, 0x00, 0x80, 0x64, 0x00, 0x00)) {
                        mstore(0x80, shl(0xe5, 0x461bcd)) 
                        mstore(0x84, 0x20)
                        mstore(0xA4, 0x12)
                        mstore(0xC4, "Insufficient token")
                        revert(0x80, 0x64)
                    }
                    // require(transferForm(origin(), owner, fee) = true)
                    if gt(fee, 0x00) {
                        mstore(0xa4, sload(0x01))
                        mstore(0xc4, sub(amt, fee))
                        if iszero(call(gas(), tka, 0x00, 0x80, 0x64, 0x00, 0x00)) {
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