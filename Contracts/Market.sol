// SPDX-License-Identifier: None
// solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Access} from "Contracts/Util/Access.sol";
import {DynamicPrice} from "Contracts/Util/DynamicPrice.sol";

contract Market is Access, DynamicPrice {
    
    event Item();

    constructor(address did) {
        assembly {
            sstore(0x0, did)
        }
    }    

    // gas: 98539
    function list(address contAddr, uint id, uint price, address tokenAddr) external {
        assembly {
            // ownerOf(id)
            mstore(0x80, 0x6352211e00000000000000000000000000000000000000000000000000000000)
            mstore(0x84, id)
            pop(staticcall(gas(), contAddr, 0x80, 0x24, 0x0, 0x20))

            // require(ownerOf(tokenId) == msg.sender, 0xf)
            if iszero(eq(mload(0x0), caller())) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0xd)
                mstore(0xC4, "Not NFT Owner")
                revert(0x80, 0x64)
            }

            // tokenAddr > 0
            if gt(tokenAddr, 0x0) {
                // isApprovedForAll(address,address)
                mstore(0x80, 0xe985e9c500000000000000000000000000000000000000000000000000000000)
                mstore(0x84, caller())
                mstore(0xa4, address())
                pop(staticcall(gas(), contAddr, 0x80, 0x44, 0x0, 0x20))
                
                // require(isApprovedForAll(msg.sender, address(this)), 0x10)
                if iszero(mload(0x0)) {
                    mstore(0x80, shl(0xe5, 0x461bcd)) 
                    mstore(0x84, 0x20)
                    mstore(0xA4, 0x13)
                    mstore(0xC4, "No isApprovedForAll")
                    revert(0x80, 0x64)
                }
            }

            // listData(address(), contAddr, tokenId, tokenAddr, price)
            mstore(0x80, 0x41aa443600000000000000000000000000000000000000000000000000000000)
            // 更新
            mstore(0x84, address())
            mstore(0xa4, contAddr)
            mstore(0xc4, id)
            mstore(0xe4, tokenAddr)
            mstore(0x104, price)
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0xa4, 0x0, 0x0))

            // emit Item()
            log1(0x0, 0x00, 0x6a7a67f0593403947073c37028291bd516867d4d24f57a76f4b94f284a63589f)
        }
    }

    // gas: 269403/292730
    function buy(address contAddr, uint id) external payable {
        address from;
        uint fee;

        assembly {
            // listData(address(), contAddr, id)
            mstore(0x80, 0xdf0188db00000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())
            mstore(0xa4, contAddr)
            mstore(0xc4, id)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x40))
            
            // require(price > 0, 0x11)
            if iszero(mload(0x20)) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0xc)
                mstore(0xC4, "Not for sale")
                revert(0x80, 0x64)
            }

            // ownerOf(id)
            mstore(0x80, 0x6352211e00000000000000000000000000000000000000000000000000000000)
            mstore(0x84, id)
            pop(staticcall(gas(), contAddr, 0x80, 0x24, 0x0, 0x20))
            from := mload(0x0)

            // 索取费用和卖家
            fee := sload(0x1)

            // emit Item()
            log1(0x0, 0x00, 0x6a7a67f0593403947073c37028291bd516867d4d24f57a76f4b94f284a63589f)
        }
        
        pay(contAddr, id, from, fee); // 转币给卖家减费用

        assembly {
            // approve(msg.sender, id)
            mstore(0x80, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(0x84, caller())
            mstore(0xa4, id)
            pop(call(gas(), contAddr, 0x0, 0x80, 0x44, 0x0, 0x0))

            // transferFrom(from, msg.sender, id)
            mstore(0x80, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(0x84, from)
            mstore(0xa4, caller())
            mstore(0xc4, id)
            pop(call(gas(), contAddr, 0x0, 0x80, 0x64, 0x0, 0x0))

            // listData(address(), contAddr, id, tokenAddr, price)
            mstore(0x80, 0x41aa443600000000000000000000000000000000000000000000000000000000)
            // 下架
            mstore(0x84, address())
            mstore(0xa4, contAddr)
            mstore(0xc4, id)
            mstore(0xe4, 0x0)
            mstore(0x104, 0x0)
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0xa4, 0x0, 0x0))
        }            
    }

    //设置费用
    function setFee(uint amt) external OnlyAccess {
        assembly {
            sstore(0x1, amt) // 小数点后两位的百分比，xxx.xx
        }
    }
    
}