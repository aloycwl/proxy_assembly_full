//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Lib.sol";
import "./Util.sol";
import "./Interfaces.sol";

contract ERC721 is IERC721, IERC721Metadata, Util{
    
    //ERC721标准变量 
    address public owner;
    mapping(uint => address) public ownerOf;
    mapping(uint => address) public getApproved;
    mapping(address => uint) public balanceOf;
    mapping(address => uint[]) private enumBalance;
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    string public name;
    string public symbol;

    //ERC721自定变量
    uint public suspended;
    uint public count = 1;
    mapping(uint => string) public uri;
    IProxy public iProxy;

    //ERC20标准函数 
    constructor(address proxy, string memory _name, string memory _sym){
        //调用交叉合约函数
        (iProxy, name, symbol, owner) = (IProxy(proxy), _name, _sym, msg.sender);
        enumBalance[address(this)].push(1);
        
    }

    //测试它是否符合 721 标准
    function supportsInterface(bytes4 a) external pure returns (bool) {
        return a == type(IERC721).interfaceId || a == type(IERC721Metadata).interfaceId;
    }

    //返回将整数转换为字符串的某个通用资源标识符
    function tokenURI(uint id) external view returns (string memory) {
        if (bytes(uri[id]).length > 0){
            return uri[id];
        }
        return string(abi.encodePacked("ipfs://someurl/", Lib.uintToString(id)));
    }

    //批准他人交易
    function approve(address to, uint id) external {
        assert(msg.sender == ownerOf[id] ||                 //是不可替代令牌的所有者
            isApprovedForAll[ownerOf[id]][msg.sender]);     //所有不可替代的代币都将出售
        emit Approval(ownerOf[id], getApproved[id] = to, id);
    }

    //所有不可替代的代币都将出售
    function setApprovalForAll(address from, bool to) external {
        emit ApprovalForAll(msg.sender, from, isApprovedForAll[msg.sender][from] = to);
    }

    //省略，因为它具有相同的功能
    function safeTransferFrom(address from, address to, uint id)external{
        transferFrom(from, to, id); 
    }

    //省略，因为它具有相同的功能
    function safeTransferFrom(address from, address to, uint id, bytes memory)external{
        transferFrom(from, to, id); 
    }

    //实际传递函数
    function transferFrom(address from, address to, uint id) public{
        unchecked{
            assert(ownerOf[id] == from ||                               //必须是所有者或
                getApproved[id] == to ||                                //已被授权
                isApprovedForAll[ownerOf[id]][from] ||                  //待全部出售
                access[msg.sender] > 0);                                //是管理员权限
            
            uint bal = balanceOf[from];
            uint[] storage enumBal = enumBalance[from];
            for (uint i; i < bal; ++i)                                  //从所有者数组中删除
                if (enumBal[i] == id) {
                    enumBal[i] = enumBal[bal - 1];
                    enumBal.pop();
                    break;
                }
            getApproved[id] = address(0);                               //重置授权
            --balanceOf[from];                                          //减少前任所有者的余额
            
            transfer(from, to, id);                                     //开始转移
        }
    }

    //自定义函数

    //切换暂停
    function toggleSuspend() external OnlyAccess {
        suspended = suspended == 0 ? 1 : 0;
    }

    //获取地址拥有的所有代币的数组
    function tokensOwned(address addr)external view returns(uint[]memory){
        return enumBalance[addr];
    }

    //通过将令牌转移到0x地址来销毁代币
    function burn(uint id) external {
        transferFrom(ownerOf[id], address(0), id);
    }

    //the is token creation function 可用于转移和铸币
    function transfer(address from, address to, uint id) private {
        unchecked {
            assert(suspended == 0);                                     //合约未被暂停
            assert(IDID(iProxy.addrs(3)).uintData(from, 0) == 0 &&      //发件人不能被列入黑名单
                IDID(iProxy.addrs(3)).uintData(to, 0) == 0);            //接收者也不能被列入黑名单

            if (to != address(0)) {
                enumBalance[msg.sender].push(id);                       //添加到新的所有者数组
                ++balanceOf[to];                                        //添加当前所有者的余额
            }

            emit Approval(ownerOf[id], ownerOf[id] = to, id);
            emit Transfer(from, to, id);
        }
    }

    //铸造功能，需要先决条件
    function mint() external payable {
        //some prerequisites
        //require(msg.value > 2e10);
        
        transfer(address(this), msg.sender, count++);
    }

    function setTokenURI(uint id, string calldata _uri) external OnlyAccess {
        uri[id] = _uri;
    }

    //burn out
}