//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Access}                   from "Contracts/Util/Access.sol";
import {Sign}                     from "Contracts/Util/Sign.sol";
import {DynamicPrice, Proxy}      from "Contracts/Util/DynamicPrice.sol";
import {DID}                      from "Contracts/DID.sol";
import {IERC721, IERC721Metadata} from "Contracts/Interfaces.sol";

contract ERC721 is IERC721, IERC721Metadata, Access, Sign, DynamicPrice {
    
    string  public  name;
    string  public  symbol;
    uint    public  suspended;
    uint    public  count;
    Proxy   private iProxy;

    //ERC20标准函数 
    constructor (address proxy, string memory _name, string memory _sym) DynamicPrice(proxy) Sign(proxy) {

        //调用交叉合约函数
        (iProxy, name, symbol) = (Proxy(proxy), _name, _sym);
        
    }

    function supportsInterface (bytes4 a) external pure returns (bool) {

        return a == type(IERC721).interfaceId || a == type(IERC721Metadata).interfaceId;

    }

    function ownerOf (uint id) public view returns (address) {

        return DID(iProxy.addrs(3)).addressData(address(this), 0, id);

    }

    function getApproved (uint id) public view returns (address) {

        return DID(iProxy.addrs(3)).addressData(address(this), 1, id);

    }

    function isApprovedForAll (address from, address to) public view returns (bool) {

        return DID(iProxy.addrs(3)).uintData(address(this), from, to) > 0 ? true : false;

    }

    function approve (address to, uint id) external {

        address ownerOfId = ownerOf(id);

        require(msg.sender == ownerOfId || isApprovedForAll(ownerOfId, msg.sender),
            "Invalid owner");             

        DID(iProxy.addrs(3)).updateAddress(address(this), 1, id, to);
        emit Approval(ownerOfId, to, id);

    }

    function setApprovalForAll (address to, bool bol) external {

        DID(iProxy.addrs(3)).updateUint(address(this), msg.sender, to, bol ? 1 : 0);
        emit ApprovalForAll(msg.sender, to, bol);

    }

    function balanceOf (address addr) public view returns (uint) {

        return DID(iProxy.addrs(3)).uintData(address(this), addr, address(0));

    }

    function tokenURI (uint id) public view returns (string memory) {

        return string.concat("ipfs://", DID(iProxy.addrs(3)).stringData(address(this), address(0), id));

    }

    function safeTransferFrom (address from, address to, uint id) external {

        transferFrom(from, to, id); 

    }

    function safeTransferFrom (address from, address to, uint id, bytes memory) external {

        transferFrom(from, to, id); 

    }

    function transferFrom (address from, address to, uint id) public {

        unchecked {

            address ownerOfId = ownerOf(id);

            require(ownerOfId == from ||                                            //必须是所有者或
                    getApproved(id) == to ||                                        //已被授权或
                    isApprovedForAll(ownerOfId, from) ||                            //待全部出售或
                    access[msg.sender] > 0, "Unathorised transfer");                //有管理员权限
            
            DID iDID = DID(iProxy.addrs(3));
            iDID.popUintEnum(address(this), from, id);                              //从所有者数组中删除
            iDID.updateAddress(address(this), 1, id, address(0));                   //重置授权
            iDID.updateUint(address(this), from, to, 0);                            //重置操作员授权
            iDID.updateUint(address(this), from, address(0), balanceOf(from) - 1);  //减少前任所有者的余额
            transfer(from, to, id);                                                 //开始转移
                                               
        }

    }

    //切换暂停
    function toggleSuspend () external OnlyAccess {

        suspended = suspended == 0 ? 1 : 0;

    }

    //获取地址拥有的所有代币的数组
    function tokensOwned (address addr) public view returns(uint[] memory) {

        return DID(iProxy.addrs(3)).uintEnumData(address(this), addr);

    }

    //通过将令牌转移到0x地址来销毁代币
    function burn (uint id) external {

        transferFrom(ownerOf(id), address(0), id);

    }

    //用于转移和铸币
    function transfer (address from, address to, uint id) private {

        unchecked {

            require(suspended == 0, "Contract is suspended");                       //合约未被暂停

            DID iDID = DID(iProxy.addrs(3));
            require(iDID.uintData(address(0), from, address(0)) == 0 &&             //发件人不能被列入黑名单
                iDID.uintData(address(0), to, address(0)) == 0, "User blacklisted");//接收者也不能被列入黑名单

            if (to != address(0)) {

                iDID.pushUintEnum(address(this), to, id);                           //添加到新的所有者数组
                iDID.updateUint(address(this), to, address(0), balanceOf(to) + 1);  //添加当前所有者的余额
                                                                    
            }

            iDID.updateAddress(address(this), 0, id, to);                           //更新NFT持有者
            emit Transfer(from, to, id);

        }

    }

    //铸造功能，需要先决条件，也用来升级或合并
    function assetify (uint _list, address addr, uint id, string calldata uri, uint8 v, bytes32 r, bytes32 s) 
        external payable {
        unchecked {
        
            //如果金额已设定，支付到地址
            pay(address(this), _list, owner, 0);

            //检查签名和更新指数
            check(addr, v, r, s);

            //如果新NFT使用count，否则使用代币id
            DID(iProxy.addrs(3)).updateString(address(this), address(0), id > 0 ? id : ++count, uri);

            //铸币
            if (id == 0) transfer(address(0), addr, count);
            //更新元数据详细信息
            else emit MetadataUpdate(id);

        }

    }

    //设置等级和价钱
    function setLevel (uint _list, address tokenAddr, uint price) external OnlyAccess {

        DID(iProxy.addrs(3)).updateList(address(this), address(this), _list, tokenAddr, price);

    }

}