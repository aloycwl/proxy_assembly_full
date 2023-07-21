//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {DID} from "Contracts/DID.sol";
import {Access} from "Contracts/Util/Access.sol";
import {DynamicPrice} from "Contracts/Util/DynamicPrice.sol";
import {ERC721} from "Contracts/ERC721.sol";

contract Market is Access, DynamicPrice {

    DID private iDID;
    uint public fee; //小数点后两位的百分比，xxx.xx
    event Item();

    constructor(address did) {
        iDID = DID(did);
        assembly {
            sstore(0x0, did)
        }
    }    

    //卖功能，需要先设置NFT合约的认可
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
            mstore(0x80, shl(0xe0, 0x6352211e)) // ownerOf(address)
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
            mstore(0x80, shl(0xe0, 0x41aa4436)) // listData(address,address,uint256,address,uint256)
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

    //用户必须发送大于或等于所列价格的以太币
    function buy(address contAddr, uint tokenId) external payable {
        (, uint price) = iDID.listData(address(this), contAddr, tokenId);
        ERC721 iERC721 = ERC721(contAddr);
        address seller  = iERC721.ownerOf(tokenId);
        require(price > 0,                                              "11");
        
        pay(contAddr, tokenId, seller, fee);                            //转币给卖家减费用
        iERC721.approve(msg.sender, tokenId);                           //手动授权给新所有者
        iERC721.transferFrom(seller, msg.sender, tokenId);
        iDID.listData(address(this), contAddr, tokenId, address(0), 0); //把币下市

        assembly {
            log1(0x0, 0x00, 0x6a7a67f0593403947073c37028291bd516867d4d24f57a76f4b94f284a63589f)
        }                 
    }

    //设置费用
    function setFee(uint amt) external OnlyAccess {
        fee = amt;
    }
    
}