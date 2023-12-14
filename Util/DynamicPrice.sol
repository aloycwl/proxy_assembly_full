// SPDX-License-Identifier: None
pragma solidity 0.8.23;
pragma abicoder v1;

import {Ownable} from "../Util/Ownable.sol";

contract DynamicPrice is Ownable {

    function _pay(bytes32 lst, address toa, uint qty) internal {
        assembly {
            let tka := sload(lst)
            let amt := mul(sload(add(lst, 0x01)), qty)
            
            if gt(tka, 0x00) { // if(tka > 0)
                let fee := div(mul(amt, sload(TFM)), 0x2710) 
                if eq(tka, 0x01) { // 转货币
                    if gt(amt, callvalue()) { // require(msg.value > amt)
                        mstore(0x80, ERR) 
                        mstore(0xa0, STR)
                        mstore(0xc0, ER5)
                        revert(0x80, 0x64)
                    }
                    pop(call(gas(), toa, sub(amt, fee), 0x00, 0x00, 0x00, 0x00)) // payable(toa).send(amt)
                    pop(call(gas(), sload(OWO), selfbalance(), 0x00, 0x00, 0x00, 0x00))
                }
                
                if gt(tka, 0x01) { // 转代币
                    mstore(0x80, TFM) // require(transferFrom(caller(), address(this), amt))
                    mstore(0x84, caller())
                    mstore(0xa4, address())
                    mstore(0xc4, amt)
                    if iszero(call(gas(), tka, 0x00, 0x80, 0x64, 0x00, 0x00)) {
                        mstore(0x80, ERR) 
                        mstore(0xa0, STR)
                        mstore(0xc0, ER5)
                        revert(0x80, 0x64)
                    }

                    mstore(0x80, TTF) // require(transfer(toa, amt))
                    mstore(0x84, toa)
                    mstore(0xa4, sub(amt, fee))
                    pop(call(gas(), tka, 0x00, 0x80, 0x44, 0x00, 0x00))
                    
                    if gt(fee, 0x00) { // require(transfer(owner(), fee))
                        mstore(0x84, sload(OWO))
                        mstore(0xa4, fee)
                        pop(call(gas(), tka, 0x00, 0x80, 0x44, 0x00, 0x00))
                    }
                }
            }
        }
    }

}