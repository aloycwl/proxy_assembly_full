//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Interfaces.sol";
import "./Util.sol";

contract NFTMarket is Util {

    struct List {
        address contractAddr;
        uint tokenId;
        uint price;
    }

    address private owner;
    uint private counter;
    uint public fee = 0; //小数点后两位的百分比，xxx.xx
    mapping(uint => List) public list;

    constructor() {
        owner = msg.sender;
    }

    //卖功能，需要先设置NFT合约的认可
    function sell(address contractAddr, uint tokenId, uint price) external {
        unchecked {
            require(IERC721(contractAddr).getApproved(tokenId) == address(this), "No approval");
            
            List storage l = list[counter];
            (l.contractAddr, l.tokenId, l.price) = (contractAddr, tokenId, price);
        }
    }

    //取消列表功能，也将在成功购买时调用
    function remove(uint id) public {
        List storage _list = list[id];
        require(IERC721(_list.contractAddr).ownerOf(_list.tokenId) == msg.sender, "Not owner");
        delete list[id];
    }

    //用户必须发送大于或等于所列价格的以太币
    function buy(uint id) external payable {
        unchecked {
            List storage l = list[id];
            (uint tokenId, uint price) = (l.tokenId, l.price);
            require(msg.value >= price, "Insufficient price");

            address seller = IERC721(l.contractAddr).ownerOf(tokenId);
            IERC721(l.contractAddr).transferFrom(seller, address(this), tokenId);
            IERC721(l.contractAddr).transferFrom(address(this), msg.sender, tokenId);

            payable(seller).transfer(price * (10000 - fee / 10000));
            payable(owner).transfer(address(this).balance);
            remove(id);
        }
    }

    //设置费用
    function setFee(uint amt) external OnlyAccess {
        fee = amt;
    }
}