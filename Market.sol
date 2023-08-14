// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {Access} from "../Util/Access.sol";
import {DynamicPrice} from "../Util/DynamicPrice.sol";

contract Market is Access, DynamicPrice {

    bytes32 constant internal STO = 0x79030946dd457157e4aa08fcb4907c422402e75f0f0ecb4f2089cb35021ff964;
    bytes32 constant internal FEE = 0x607744c37698f0ad2c7e8b300d57eaef2f987ccbb958ce7cd316a2c3e663f9ec;
    bytes32 constant internal OWO = 0x6352211e00000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal AFA = 0xe985e9c500000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal APP = 0x095ea7b300000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal TTF = 0x23b872dd00000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal LIS = 0xdf0188db00000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal LID = 0x41aa443600000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal ERR = 0x08c379a000000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal ITM = 0x6a7a67f0593403947073c37028291bd516867d4d24f57a76f4b94f284a63589f;

    event Item();

    constructor(address sto) {
        assembly {
            sstore(STO, sto)
        }
    }    

    // gas: 98539
    function list(address contAddr, uint id, uint price, address tokenAddr) external {
        assembly {
            // ownerOf(id)
            mstore(0x80, OWO)
            mstore(0x84, id)
            pop(staticcall(gas(), contAddr, 0x80, 0x24, 0x00, 0x20))

            // require(ownerOf(tokenId) == msg.sender, 0xf)
            if iszero(eq(mload(0x0), caller())) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x0d)
                mstore(0xC4, "Invalid Owner")
                revert(0x80, 0x64)
            }

            // tokenAddr > 0
            if gt(tokenAddr, 0x0) {
                // isApprovedForAll(address,address)
                mstore(0x80, AFA)
                mstore(0x84, caller())
                mstore(0xa4, address())
                pop(staticcall(gas(), contAddr, 0x80, 0x44, 0x00, 0x20))
                
                // require(isApprovedForAll(msg.sender, address(this)), 0x10)
                if iszero(mload(0x0)) {
                    mstore(0x80, ERR) 
                    mstore(0x84, 0x20)
                    mstore(0xA4, 0x11)
                    mstore(0xC4, "No ApprovedForAll")
                    revert(0x80, 0x64)
                }
            }

            // listData(address(), contAddr, tokenId, tokenAddr, price)
            mstore(0x80, LID)
            // 更新
            mstore(0x84, address())
            mstore(0xa4, contAddr)
            mstore(0xc4, id)
            mstore(0xe4, tokenAddr)
            mstore(0x0104, price)
            pop(call(gas(), sload(STO), 0x00, 0x80, 0xa4, 0x00, 0x00))

            // emit Item()
            log1(0x00, 0x00, ITM)
        }
    }

    // gas: 269403/292730
    function buy(address adr, uint tid) external payable {
        address frm;
        uint amt;

        assembly {
            // listData(address(), contAddr, id)
            mstore(0x80, LIS)
            mstore(0x84, address())
            mstore(0xa4, adr)
            mstore(0xc4, tid)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x40))
            
            // require(price > 0, 0x11)
            if iszero(mload(0x20)) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0xc)
                mstore(0xC4, "Not for sale")
                revert(0x80, 0x64)
            }

            // ownerOf(id)
            mstore(0x80, OWO)
            mstore(0x84, tid)
            pop(staticcall(gas(), adr, 0x80, 0x24, 0x00, 0x20))
            frm := mload(0x0)

            // 索取费用和卖家
            amt := sload(FEE)

            // emit Item()
            log1(0x00, 0x00, ITM)
        }
        
        pay(adr, tid, frm, amt); // 转币给卖家减费用

        assembly {
            // approve(msg.sender, id)
            mstore(0x80, APP)
            mstore(0x84, caller())
            mstore(0xa4, tid)
            pop(call(gas(), adr, 0x00, 0x80, 0x44, 0x00, 0x00))

            // transferFrom(from, msg.sender, id)
            mstore(0x80, TTF)
            mstore(0x84, frm)
            mstore(0xa4, caller())
            mstore(0xc4, tid)
            pop(call(gas(), adr, 0x00, 0x80, 0x64, 0x00, 0x00))

            // listData(address(), contAddr, id, tokenAddr, price)
            mstore(0x80, LID)
            // 下架
            mstore(0x84, address())
            mstore(0xa4, adr)
            mstore(0xc4, tid)
            mstore(0xe4, 0x0)
            mstore(0x0104, 0x0)
            pop(call(gas(), sload(STO), 0x00, 0x80, 0xa4, 0x00, 0x00))
        }            
    }

    //设置费用
    function setFee(uint amt) external onlyAccess {
        assembly {
            sstore(FEE, amt) // 小数点后两位的百分比，xxx.xx
        }
    }

    function fee() external view returns (uint) {
        assembly {
            mstore(0x00, sload(FEE))
            return(0x00, 0x20)
        }
    }
    
}