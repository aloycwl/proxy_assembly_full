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

    // 卖功能，需要先设置NFT合约的认可
    function list(address contAddr, uint tokenId, uint price, address tokenAddr) external {
        assembly {
            function x(con, cod) { // Error(bytes32)
                if iszero(con) {
                    mstore(0x0, shl(0xe0, 0x5b4fb734))
                    mstore(0x4, cod)
                    revert(0x0, 0x24)
                }
            }
            // require(ownerOf(tokenId) == msg.sender, 0xf)
            mstore(0x80, shl(0xe0, 0x6352211e)) // ownerOf(uint256)
            mstore(0x84, tokenId)
            pop(staticcall(gas(), contAddr, 0x80, 0x24, 0x0, 0x20))
            x(eq(mload(0x0), caller()), 0xf) 
            // require(isApprovedForAll(msg.sender, address(this)), 0x10)
            if gt(price, 0x0) {
                mstore(0x80, shl(0xe0, 0xe985e9c5)) // isApprovedForAll(address,address)
                mstore(0x84, caller())
                mstore(0xa4, address())
                pop(staticcall(gas(), contAddr, 0x80, 0x44, 0x0, 0x20))
                x(mload(0x0), 0x10)
            }
            // 上架
            mstore(0x80, shl(0xe0, 0xd18524af)) // store(bytes32,bytes32,bytes32,bytes32,bytes32)
            mstore(0x84, address())
            mstore(0xa4, contAddr)
            mstore(0xc4, tokenId)
            mstore(0xe4, tokenAddr)
            mstore(0x104, price)
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0xa4, 0x0, 0x0))
            // emit Item()
            log1(0x0, 0x00, 0x6a7a67f0593403947073c37028291bd516867d4d24f57a76f4b94f284a63589f)
        }
    }

    // 币或代币
    function buy(address contAddr, uint tokenId) external payable {
        address seller;
        uint fee;

        assembly {
            mstore(0x80, shl(0xe0, 0xdf0188db)) // listData(address,address,uint256)
            mstore(0x84, address())
            mstore(0xa4, contAddr)
            mstore(0xc4, tokenId)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x40))
            // require(price > 0, 0x11)
            if iszero(mload(0x20)) {
                mstore(0x0, shl(0xe0, 0x5b4fb734))
                mstore(0x4, 0x11)
                revert(0x0, 0x24)
            }
            // 索取费用和卖家
            fee := sload(0x1)
            mstore(0x80, shl(0xe0, 0x6352211e)) // ownerOf(uint256)
            mstore(0x84, tokenId)
            pop(staticcall(gas(), contAddr, 0x80, 0x24, 0x0, 0x20))
            seller := mload(0x0)
            // emit Item()
            log1(0x0, 0x00, 0x6a7a67f0593403947073c37028291bd516867d4d24f57a76f4b94f284a63589f)
        }
        
        pay(contAddr, tokenId, seller, fee); // 转币给卖家减费用

        assembly {
            // 手动授权给新所有者
            mstore(0x80, shl(0xe0, 0x095ea7b3)) // approve(address,uint256)
            mstore(0x84, caller())
            mstore(0xa4, tokenId)
            pop(call(gas(), contAddr, 0x0, 0x80, 0x44, 0x0, 0x0))
            // 转币
            mstore(0x80, shl(0xe0, 0x23b872dd)) // transferFrom(address,address,uint256)
            mstore(0x84, 0x0)
            mstore(0xa4, caller())
            mstore(0xc4, tokenId)
            pop(call(gas(), contAddr, 0x0, 0x80, 0x64, 0x0, 0x0))
            // 下架
            mstore(0x80, shl(0xe0, 0xd18524af)) // store(bytes32,bytes32,bytes32,bytes32,bytes32)
            mstore(0x84, address())
            mstore(0xa4, contAddr)
            mstore(0xc4, tokenId)
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