//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Util.sol";

struct Level {

    address contAddr;
    uint price;

}

contract ERC721 is IERC721, IERC721Metadata, Access, Sign {
    
    address                 public  owner;
    string                  public  name;
    string                  public  symbol;
    uint                    public  suspended;
    uint                    public  count;
    mapping(uint => Level)  public  level;

    //ERC20标准函数 
    constructor(address proxy, string memory _name, string memory _sym) Sign(proxy) {

        //调用交叉合约函数
        (name, symbol, owner) = (_name, _sym, msg.sender);
        
    }

    function supportsInterface(bytes4 a) external pure returns (bool) {

        return a == type(IERC721).interfaceId || a == type(IERC721Metadata).interfaceId;

    }

    function ownerOf(uint id) public view returns (address) {

        return IDID(iProxy.addrs(3)).uint2Data(id, 5);

    }

    function getApproved(uint id) public view returns (address) {

        return IDID(iProxy.addrs(3)).uint2Data(id, 6);

    }

    function isApprovedForAll(address from, address to) public view returns (bool) {

        return IDID(iProxy.addrs(3)).uintAddrData(from, to, 5) > 0 ? true : false;

    }

    function approve(address to, uint id) external {

        require(msg.sender == ownerOf(id) || isApprovedForAll(ownerOf(id), msg.sender),
            "Invalid owner");             

        IDID(iProxy.addrs(3)).updateUint2(id, 6, to);
        emit Approval(ownerOf(id), to, id);

    }

    function setApprovalForAll(address to, bool bol) external {

        IDID(iProxy.addrs(3)).updateUintAddr(msg.sender, to, 5, bol ? 1 : 0);
        emit ApprovalForAll(msg.sender, to, bol);

    }

    function balanceOf(address addr) public view returns (uint) {

        return IDID(iProxy.addrs(3)).uintData(addr, 5);

    }

    function tokenURI(uint id) public view returns (string memory) {

        return IDID(iProxy.addrs(3)).stringData(ownerOf(id), id, 5);

    }

    function safeTransferFrom(address from, address to, uint id) external {

        transferFrom(from, to, id); 

    }

    function safeTransferFrom(address from, address to, uint id, bytes memory) external {

        transferFrom(from, to, id); 

    }

    function transferFrom(address from, address to, uint id) public{

        unchecked{

            assert( ownerOf(id) == from ||                              //必须是所有者或
                    getApproved(id) == to ||                            //已被授权或
                    isApprovedForAll(ownerOf(id), from) ||              //待全部出售或
                    access[msg.sender] > 0);                            //有管理员权限
            
            IDID iDID = IDID(iProxy.addrs(3));
            iDID.popUintEnum(from, 5, id);                              //从所有者数组中删除
            iDID.updateUint2(id, 6, address(0));                        //重置授权
            iDID.updateUintAddr(from, to, 5, 0);                        //重置操作员授权
            iDID.updateUint(to, 5, balanceOf(from) - 1);                //减少前任所有者的余额
            transfer(from, to, id);                                     //开始转移
                                               
        }

    }

    //切换暂停
    function toggleSuspend() external OnlyAccess {

        suspended = suspended == 0 ? 1 : 0;

    }

    //获取地址拥有的所有代币的数组
    function tokensOwned(address addr) public view returns(uint[] memory) {

        return IDID(iProxy.addrs(3)).uintEnumData(addr, 5);

    }

    //通过将令牌转移到0x地址来销毁代币
    function burn(uint id) external {

        transferFrom(ownerOf(id), address(0), id);

    }

    //用于转移和铸币
    function transfer(address from, address to, uint id) private {

        unchecked {

            require(suspended == 0, "Contract is suspended");           //合约未被暂停

            IDID iDID = IDID(iProxy.addrs(3));
            if(address(iProxy) != address(0))
                require(iDID.uintData(from, 0) == 0 &&                  //发件人不能被列入黑名单
                    iDID.uintData(to, 0) == 0, "User is blacklisted");  //接收者也不能被列入黑名单

            if (to != address(0)) {

                iDID.pushUintEnum(msg.sender, 5, id);                   //添加到新的所有者数组
                iDID.updateUint(to, 5, balanceOf(to) + 1);                //添加当前所有者的余额
                                                                    
            }

            iDID.updateUint2(id, 5, to);                                //更新NFT持有者
            emit Approval(ownerOf(id), to, id);                         //日志
            emit Transfer(from, to, id);

        }

    }

    //铸造功能，需要先决条件，也用来升级或合并
    function assetify(uint _level, address addr, uint id, string calldata uri, uint8 v, bytes32 r, bytes32 s) 
        external payable {
        unchecked {
        
            Level storage lv = level[_level];
            (address contAddr, uint price) = (lv.contAddr, lv.price);

            //如果级别有价格要求，检查用户是否正确发送了价格
            if (price > 0) 
                //如果不指定地址，则转入主币，否则从合约地址转入
                if (contAddr == address(0)) {

                    require(msg.value >= price, "Insufficient amount");
                    payable(owner).transfer(address(this).balance);

                } else {

                    IERC20 iERC20 = IERC20(contAddr);
                    require(iERC20.transfer(address(this), price), "Insufficient amount");
                    iERC20.transfer(owner, price);

                }

            //检查签名和更新指数
            check(addr, v, r, s);

            //如果新NFT使用count，否则使用代币id
            IDID(iProxy.addrs(3)).updateString(msg.sender, id > 0 ? id : ++count, 5, uri);

            //铸币
            if (id == 0) transfer(address(this), addr, count);
            //更新元数据详细信息
            else emit MetadataUpdate(id);

        }

    }

    //根据合约类型和级别设置定价
    function setLevel(uint _level, address contAddr, uint price) external OnlyAccess {

        Level storage lv = level[_level];
        (lv.contAddr, lv.price) = (contAddr, price);

    }

}