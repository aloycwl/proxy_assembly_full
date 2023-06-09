//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Util.sol";

contract NFTMarket is Access {

    address private owner;
    uint    public fee; //小数点后两位的百分比，xxx.xx
    mapping(address => mapping(uint => uint)) public list;

    constructor() {

        owner = msg.sender;

    }

    //卖功能，需要先设置NFT合约的认可
    function sell(address contractAddr, uint tokenId, uint price) external {

        require(IERC721(contractAddr).ownerOf(tokenId) == msg.sender,               "Not owner");
        require(IERC721(contractAddr).isApprovedForAll(msg.sender, address(this)),  "No approval");
        list[contractAddr][tokenId] = price;

    }

    //取消列表功能，也将在成功购买时调用
    function remove(address contractAddr, uint tokenId) public {

        require(IERC721(contractAddr).ownerOf(tokenId) == msg.sender,               "Not owner");
        delete list[contractAddr][tokenId];

    }

    //用户必须发送大于或等于所列价格的以太币
    function buy(address contractAddr, uint tokenId) external payable {

        unchecked {

            uint price = list[contractAddr][tokenId];
            require(price > 0,                                                      "Item is not for sale");
            require(msg.value >= price,                                             "Insufficient price");

            IERC721 iERC721 = IERC721(contractAddr);
            address seller = iERC721.ownerOf(tokenId);

            //需要 ApproveForAll
            iERC721.approve(msg.sender, tokenId);
            iERC721.transferFrom(seller, msg.sender, tokenId);

            //payable(seller).transfer(price / 10000 * (10000 - fee));  //1000000000000000000
            //uint amt = 1e4 - fee;
            payable(seller).transfer(price * (1e4 - fee) / 1e4);
            payable(owner).transfer(address(this).balance);
            remove(contractAddr, tokenId);

        }

    }

    //设置费用
    function setFee(uint amt) external OnlyAccess {

        fee = amt;

    }
    
}