//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Interfaces.sol";
import "./Util.sol";

contract agora is Util {

    struct List {
        address contractAddr;
        uint tokenId;
        uint price;
    }

    uint public listed;
    uint public fee = 0; //小数点后两位的百分比，xxx.xx 
    address private _owner;
    mapping(uint => List) public list;

    constructor() {
        _owner = msg.sender;
    }

    function Sell(address _nftAdd, uint _tokenId, uint _price) external {
        unchecked {
            require(IERC721(_nftAdd).getApproved(_tokenId) == address(this));
            require(IERC721(_nftAdd).ownerOf(_tokenId) == msg.sender);
            List storage l = list[listed];
            (l.contractAddr, l.tokenId, l.price) = (_nftAdd, _tokenId, _price);
            ++listed;
        }
    }

    function Buy(uint _id) external payable {
        unchecked {
            List storage l = list[_id];
            uint _price = l.price;
            require(msg.value >= _price);
            address seller = IERC721(l.contractAddr).ownerOf(l.tokenId);
            IERC721(l.contractAddr).transferFrom(seller, address(this), l.tokenId);
            IERC721(l.contractAddr).transferFrom(address(this), msg.sender, l.tokenId);
            payable(seller).transfer(_price * (10000 - fee / 10000));
            payable(_owner).transfer(address(this).balance);
            delete list[_id];
        }
    }

    function Show(uint batch,  uint offset) external view returns
        (string[]memory tu, uint[]memory price, uint[]memory listId) {
            unchecked{
            (tu, price, listId) = (new string[](batch), new uint[](batch), new uint[](batch));
            uint b;
            uint i = listed - offset;
            while(b < batch && i > 0) {
                List storage l = list[--i];
                if(IERC721(l.contractAddr).getApproved(l.tokenId) == address(this)) {
                    ++b;
                    (tu[b], price[b], listId[b]) = (IERC721Metadata(l.contractAddr).tokenURI(l.tokenId), l.price, i);
                }
                --i;
            }
        }
    }

    //get individual listing information

    //delist the item

    function setFee(uint amt) external OnlyAccess {
        fee = amt;
    }
}