//SPDX-License-Identifier:None
pragma solidity ^0.8.0;

import "Contracts/Util/DynamicPrice.sol";
import "Contracts/Interfaces.sol";

contract NFTMarket is Access, DynamicPrice {

    uint public fee; //小数点后两位的百分比，xxx.xx

    //卖功能，需要先设置NFT合约的认可
    function list (address contractAddr, uint tokenId, uint price, address tokenAddr) external {

        IERC721 iERC721 = IERC721(contractAddr);

        require(iERC721.ownerOf(tokenId) == msg.sender,                             "Not owner");
        require(iERC721.isApprovedForAll(msg.sender, address(this)),                "No approval");
        
        lists[contractAddr][tokenId] = List(tokenAddr, price);

    }

    //取消列表功能，也将在成功购买时调用
    function delist (address contractAddr, uint tokenId) public {

        require(IERC721(contractAddr).ownerOf(tokenId) == msg.sender,               "Not owner");
        delete lists[contractAddr][tokenId];

    }

    //用户必须发送大于或等于所列价格的以太币
    function buy (address contAddr, uint tokenId) external payable {

        unchecked {

            uint price = lists[contAddr][tokenId].price;
            require(price > 0,                                                      "Item is not for sale");
            require(msg.value >= price,                                             "Insufficient price");

            IERC721 iERC721 = IERC721(contAddr);
            address seller  = iERC721.ownerOf(tokenId);

            iERC721.approve(msg.sender, tokenId);                                   //手动授权给新所有者
            iERC721.transferFrom(seller, msg.sender, tokenId);

            pay(contAddr, tokenId, seller, fee);                                    //转币给卖家减费用
            pay(contAddr, tokenId, owner, 0);                                       //若有剩余币转给行政
            
            delist(contAddr, tokenId);                                              //把币下市

        }

    }

    //设置费用
    function setFee (uint amt) external OnlyAccess {

        fee = amt;

    }
    
}