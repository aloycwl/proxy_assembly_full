//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import {DID, DynamicPrice, IERC721, Access} from "Contracts/ERC721.sol";

contract Market is Access, DynamicPrice {

    DID private iDID;

    event Item(address contAddr, address tokenAddr, uint tokenId, uint price);

    constructor(address did) DynamicPrice(did) {

        iDID = DID(did);

     }

    uint public fee; //小数点后两位的百分比，xxx.xx

    //卖功能，需要先设置NFT合约的认可
    function list(address contAddr, uint tokenId, uint price, address tokenAddr) external {

        IERC721 iERC721 = IERC721(contAddr);

        require(iERC721.ownerOf(tokenId) == msg.sender,                 "Not owner");
        require(iERC721.isApprovedForAll(msg.sender, address(this)),    "No approval");

        iDID.updateList(address(this), contAddr, tokenId, tokenAddr, price);

        emit Item(contAddr, tokenAddr, tokenId, price);

    }

    //取消列表功能，也将在成功购买时调用
    function delist(address contAddr, uint tokenId) public {

        require(IERC721(contAddr).ownerOf(tokenId) == msg.sender,       "Not owner");
        iDID.deleteList(address(this), contAddr, tokenId);

        emit Item(contAddr, address(0), tokenId, 0);

    }

    //用户必须发送大于或等于所列价格的以太币
    function buy(address contAddr, uint tokenId) external payable {

        unchecked {

            (, uint price) = iDID.lists(address(this), contAddr, tokenId);
            require(price > 0,                                          "Item is not for sale");

            IERC721 iERC721 = IERC721(contAddr);
            address seller  = iERC721.ownerOf(tokenId);

            iERC721.approve(msg.sender, tokenId);                       //手动授权给新所有者
            iERC721.transferFrom(seller, msg.sender, tokenId);

            pay(contAddr, tokenId, seller, fee);                        //转币给卖家减费用
            
            delist(contAddr, tokenId);                                  //把币下市

        }

    }

    //设置费用
    function setFee(uint amt) external OnlyAccess {

        fee = amt;

    }
    
}