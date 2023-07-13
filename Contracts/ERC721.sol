//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Sign}                      from "Contracts/Util/Sign.sol";
import {DID, Access, DynamicPrice} from "Contracts/Util/DynamicPrice.sol";

interface IERC721 {

    event    Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event    Approval(address indexed owner, address indexed approved, uint indexed tokenId);
    event    ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event    MetadataUpdate(uint);

    function balanceOf(address)                                        external view returns(uint);
    function ownerOf(uint)                                             external view returns(address);
    function safeTransferFrom(address, address, uint)                  external;
    function transferFrom(address, address, uint)                      external;
    function approve(address, uint)                                    external;
    function getApproved(uint)                                         external view returns(address);
    function setApprovalForAll(address, bool)                          external;
    function isApprovedForAll(address, address)                        external view returns(bool);
    function safeTransferFrom(address, address, uint, bytes calldata)  external;

}

interface IERC721Metadata {

    function name()                                                    external view returns(string memory);
    function symbol()                                                  external view returns(string memory);
    function tokenURI(uint)                                            external view returns(string memory);

}

contract ERC721 is IERC721, IERC721Metadata, Access, Sign, DynamicPrice {
    
    string public  name;
    string public  symbol;
    uint   public  suspended;
    uint   public  count;

    //ERC20标准函数 
    constructor(address did, string memory _name, string memory _sym) DynamicPrice(did) Sign(did) {

        //调用交叉合约函数
        (name, symbol) = (_name, _sym);
        
    }

    function supportsInterface(bytes4 a) external pure returns(bool) {

        return a == type(IERC721).interfaceId || a == type(IERC721Metadata).interfaceId;

    }

    function ownerOf(uint id) public view returns(address) {

        return iDID.addressData(address(this), 0, id);

    }

    function getApproved(uint id) public view returns(address) {

        return iDID.addressData(address(this), 1, id);

    }

    function isApprovedForAll(address from, address to) public view returns(bool) {

        return iDID.uintData(address(this), from, to) > 0 ? true : false;

    }

    function approve(address to, uint id) external {

        address ownerOfId = ownerOf(id);

        require(msg.sender == ownerOfId || isApprovedForAll(ownerOfId, msg.sender), "0B");             

        iDID.addressData(address(this), 1, id, to);
        emit Approval(ownerOfId, to, id);

    }

    function setApprovalForAll(address to, bool bol) external {

        iDID.uintData(address(this), msg.sender, to, bol ? 1 : 0);
        emit ApprovalForAll(msg.sender, to, bol);
        //0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31

    }

    function balanceOf(address addr) public view returns (uint) {

        return iDID.uintData(address(this), addr, address(0));

    }

    function tokenURI(uint id) public view returns (string memory) {

        return string.concat("ipfs://", iDID.stringData(address(this), id));

    }

    function safeTransferFrom(address from, address to, uint id) external {

        transferFrom(from, to, id); 

    }

    function safeTransferFrom(address from, address to, uint id, bytes memory) external {

        transferFrom(from, to, id); 

    }

    function transferFrom(address from, address to, uint id) public {

        unchecked {

            address ownerOfId = ownerOf(id);

            require(ownerOfId == from ||                                            //必须是所有者或
                    getApproved(id) == to ||                                        //已被授权或
                    isApprovedForAll(ownerOfId, from) ||                            //待全部出售或
                    this.access(msg.sender) > 0,                                    "0C");
            
            iDID.uintEnumPop(address(this), from, id);                              //从所有者数组中删除
            iDID.addressData(address(this), 1, id, address(0));                     //重置授权
            iDID.uintData(address(this), from, to, 0);                              //重置操作员授权
            iDID.uintData(address(this), from, address(0), balanceOf(from) - 1);    //减少前任所有者的余额
            transfer(from, to, id);                                                 //开始转移
                                               
        }

    }

    //切换暂停
    function toggleSuspend() external OnlyAccess {

        suspended = suspended == 0 ? 1 : 0;

    }

    //获取地址拥有的所有代币的数组
    function tokensOwned(address addr) public view returns(uint[] memory) {

        return iDID.uintEnum(address(this), addr);

    }

    //通过将令牌转移到0x地址来销毁代币
    function burn(uint id) external {

        transferFrom(ownerOf(id), address(0), id);

    }

    //用于转移和铸币
    function transfer(address from, address to, uint id) private {

        unchecked {

            require(suspended == 0,                                                 "0D");

            require(iDID.uintData(address(0), from, address(0)) == 0 &&             //发件人不能被列入黑名单
                iDID.uintData(address(0), to, address(0)) == 0,                     "0E");

            if (to != address(0)) {

                iDID.uintEnumPush(address(this), to, id);                           //添加到新的所有者数组
                iDID.uintData(address(this), to, address(0), balanceOf(to) + 1);    //添加当前所有者的余额
                                                                    
            }

            iDID.addressData(address(this), 0, id, to);                             //更新NFT持有者
            emit Transfer(from, to, id);

        }

    }

    //铸造功能，需要先决条件，也用来升级或合并
    function assetify(uint l, address a, uint i, string calldata u, uint8 v, bytes32 r, bytes32 s) external payable {

        unchecked {
        
            pay(address(this), l, this.owner(), 0);                                 //若金额设定就支付
            
            check(a, v, r, s);                                                      //检查签名和更新指数

            iDID.stringData(address(this), i > 0 ? i : ++count, u);                 //更新或铸新

            if (i == 0) transfer(address(0), a, count);                             //铸币
            
            else emit MetadataUpdate(i);                                            //更新元数据详细信息

        }

    }

    //设置等级和价钱
    function setLevel(uint _list, address tokenAddr, uint price) external OnlyAccess {

        iDID.listData(address(this), address(this), _list, tokenAddr, price);

    }

    
    /*** TESTING ONLY ***/
    function assetify() external payable {
        
            iDID.stringData(address(this), ++count, "ipfs://someJSON");
            transfer(address(0), msg.sender, count);

    }

}