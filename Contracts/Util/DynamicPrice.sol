//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {DID, ERC20, Access} from "Contracts/ERC20.sol";

contract DynamicPrice {

    error Err(bytes32);

    constructor(address did) {
        assembly {
            sstore(0x0, did)
            sstore(0x1, origin())
        }
    }

    function owner() public view returns (address a) {
        assembly {
            a := sload(0x1)
        }
    }

    function pay(address contAddr, uint _list, address to, uint fee) internal {
        unchecked {
            assembly {
                let ptr := mload(0x40)
                mstore(ptr, shl(0xe0, 0xdf0188db)) // listData(address,address,uint256)
                mstore(add(ptr, 0x04), address())
                mstore(add(ptr, 0x24), contAddr)
                mstore(add(ptr, 0x44), _list)
                pop(staticcall(gas(), sload(0x0), ptr, 0x64, 0x0, 0x40))
                let tokenAddr := mload(0x0)
                let price := mload(0x20)
                // 有价格才执行
                if gt(price, 0x0) {
                    fee := div(mul(price, sub(0x2710, fee)), 0x2710)
                    function x(cod) {
                        mstore(0x0, shl(0xe0, 0x5b4fb734))
                        mstore(0x4, cod)
                        revert(0x0, 0x24)
                    }
                    // 这是转加密货币
                    if iszero(tokenAddr) {
                        if gt(price, callvalue()) { 
                            x(0x4)
                        }
                        pop(call(gas(), to, fee, 0x0, 0x0, 0x0, 0x0))
                        pop(call(gas(), sload(0x1), selfbalance(), 0x0, 0x0, 0x0, 0x0))
                    }
                    // 这是转ERC20代币
                    if gt(tokenAddr, 0) {
                        mstore(ptr, shl(0xe0, 0x23b872dd)) // transferFrom(address,address,uint256)
                        mstore(add(ptr, 0x04), origin())
                        mstore(add(ptr, 0x24), to)
                        mstore(add(ptr, 0x44), fee)
                        if iszero(call(gas(), tokenAddr, 0x0, ptr, 0x64, 0x0, 0x0)) {
                            x(0x5)
                        }
                        mstore(add(ptr, 0x24), sload(0x1))
                        mstore(add(ptr, 0x44), sub(price, fee))
                        if iszero(call(gas(), tokenAddr, 0x0, ptr, 0x64, 0x0, 0x0)) {
                            x(0x5)
                        }
                    }
                }
            }
        }
    }
}