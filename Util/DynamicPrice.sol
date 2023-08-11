// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

contract DynamicPrice {

    bytes32 constant private STO = 0x79030946dd457157e4aa08fcb4907c422402e75f0f0ecb4f2089cb35021ff964;
    bytes32 constant private OWN = 0x658a3ae51bffe958a5b16701df6cfe4c3e73eac576c08ff07c35cf359a8a002e;
    bytes32 constant private LI2 = 0xdf0188db00000000000000000000000000000000000000000000000000000000;
    bytes32 constant private TTF = 0x23b872dd00000000000000000000000000000000000000000000000000000000;
    bytes32 constant private ERR = 0x08c379a000000000000000000000000000000000000000000000000000000000;

    constructor() {
        assembly {
            sstore(OWN, caller())
        }
    }

    function owner() external view returns (address a) {
        assembly {
            a := sload(OWN)
        }
    }

    function pay(address adr, uint lst, address toa, uint fee) internal {
        assembly {
            // 索取List
            mstore(0x80, LI2) // listData(address,address,uint256)
            mstore(0x84, address())
            mstore(0xa4, adr)
            mstore(0xc4, lst)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x40))
            let tka := mload(0x00)
            let amt := mload(0x20)
            // 有价格才执行
            if gt(tka, 0x00) {
                fee := div(mul(amt, sub(0x2710, fee)), 0x2710)
                // 这是转加密货币
                if eq(tka, 0x1) {
                    // require(msg.value > amt)
                    if gt(amt, callvalue()) { 
                        mstore(0x80, ERR) 
                        mstore(0x84, 0x20)
                        mstore(0xA4, 0x0b)
                        mstore(0xC4, "Invalid fee")
                        revert(0x80, 0x64)
                    }
                    pop(call(gas(), toa, fee, 0x00, 0x00, 0x00, 0x00))
                    pop(call(gas(), sload(OWN), selfbalance(), 0x00, 0x00, 0x00, 0x00))
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
                        mstore(0x80, ERR) 
                        mstore(0x84, 0x20)
                        mstore(0xA4, 0x0b)
                        mstore(0xC4, "Invalid fee")
                        revert(0x80, 0x64)
                    }
                    // require(transferForm(origin(), owner, fee) = true)
                    if gt(fee, 0x00) {
                        mstore(0xa4, sload(OWN))
                        mstore(0xc4, sub(amt, fee))
                        if iszero(call(gas(), tka, 0x00, 0x80, 0x64, 0x00, 0x00)) {
                            mstore(0x80, ERR) 
                            mstore(0x84, 0x20)
                            mstore(0xA4, 0x0b)
                            mstore(0xC4, "Invalid fee")
                            revert(0x80, 0x64)
                        }
                    }
                }
            }
        }
    }
}