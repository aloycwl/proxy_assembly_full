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

        IERC721 i721 = IERC721(contAddr);

        require(i721.ownerOf(tokenId) == msg.sender,                    "0F");

        if(price > 0) {

            require(i721.isApprovedForAll(msg.sender, address(this)),   "10");
            iDID.updateList(address(this), contAddr, tokenId, tokenAddr, price);

        } else

            iDID.deleteList(address(this), contAddr, tokenId);

    }

    //用户必须发送大于或等于所列价格的以太币
    function buy(address contAddr, uint tokenId) external payable {

        (, uint price) = iDID.lists(address(this), contAddr, tokenId);
        IERC721 iERC721 = IERC721(contAddr);
        address seller  = iERC721.ownerOf(tokenId);

        require(price > 0,                                              "11");

        pay(contAddr, tokenId, seller, fee);                            //转币给卖家减费用
        iERC721.approve(msg.sender, tokenId);                           //手动授权给新所有者
        iERC721.transferFrom(seller, msg.sender, tokenId);
        iDID.deleteList(address(this), contAddr, tokenId);              //把币下市                        

    }

    //设置费用
    function setFee(uint amt) external OnlyAccess {

        fee = amt;

    }
    
}