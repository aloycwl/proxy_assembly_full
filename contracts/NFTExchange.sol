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

    address private owner;
    uint private counter;
    uint public fee = 0; //小数点后两位的百分比，xxx.xx 
    uint[] public arrList;
    mapping(uint => List) public list;

    constructor() {
        owner = msg.sender;
    }

    //卖功能，需要先设置NFT合约的认可
    function sell(address contractAddr, uint tokenId, uint price) external {
        unchecked {
            assert(IERC721(contractAddr).getApproved(tokenId) == address(this));
            
            List storage l = list[counter];
            (l.contractAddr, l.tokenId, l.price) = (contractAddr, tokenId, price);
            arrList.push(++counter);
        }
    }

    //取消列表功能，也将在成功购买时调用
    function remove(uint id) public {
        unchecked{
            uint count = arrList.length;
            for (uint i; i < count; ++i)
                if (arrList[i] == id) {
                    arrList[i] = arrList[count - 1];
                    arrList.pop();
                    break;
                }
            delete list[id];
        }
    }

    //用户必须发送大于或等于所列价格的以太币
    function buy(uint id) external payable {
        unchecked {
            List storage l = list[id];
            (uint tokenId, uint price) = (l.tokenId, l.price);
            assert(msg.value >= price);

            address seller = IERC721(l.contractAddr).ownerOf(tokenId);
            IERC721(l.contractAddr).transferFrom(seller, address(this), tokenId);
            IERC721(l.contractAddr).transferFrom(address(this), msg.sender, tokenId);

            payable(seller).transfer(price * (10000 - fee / 10000));
            payable(owner).transfer(address(this).balance);
            remove(id);
        }
    }

    //分页显示
    function display(uint batch,  uint offset) external view returns
        (uint[]memory listId, uint[]memory price, string[]memory tokenUri) {
        unchecked{
            (tokenUri, price, listId) = (new string[](batch), new uint[](batch), new uint[](batch));
            uint b;
            uint len = arrList.length;
            uint i = len > offset ? len - offset : offset;
            while(b < batch && i > 0) {
                List storage l = list[--i];
                if(IERC721(l.contractAddr).getApproved(l.tokenId) == address(this)) {
                    ++b;
                    (tokenUri[b], price[b], listId[b]) = (IERC721Metadata(l.contractAddr).tokenURI(l.tokenId), l.price, i);
                }
                --i;
            }
        }
    }

    //行政功能

    function setFee(uint amt) external OnlyAccess {
        fee = amt;
    }
}