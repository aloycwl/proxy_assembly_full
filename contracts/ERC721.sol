//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Lib.sol";
import "./Util.sol";
import "./Interfaces.sol";
import "./Sign.sol";

struct Level {

    address contAddr;
    uint price;

}

contract ERC721 is IERC721, IERC721Metadata, Util, Sign {
    
    //ERC721标准变量 
    address public owner;
    mapping(uint => string) public tokenURI;
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
    IProxy private iProxy;
    mapping(uint => Level) public level;

    //ERC20标准函数 
    constructor(address proxy, string memory _name, string memory _sym) Sign (proxy) {

        //调用交叉合约函数
        (iProxy, name, symbol, owner) = (IProxy(proxy), _name, _sym, msg.sender);
        enumBalance[address(this)].push(1);
        
    }

    //测试它是否符合 721 标准
    function supportsInterface(bytes4 a) external pure returns (bool) {

        return a == type(IERC721).interfaceId || a == type(IERC721Metadata).interfaceId;

    }

    //批准他人交易
    function approve(address to, uint id) external {

        assert(msg.sender == ownerOf[id] ||                 //是不可替代令牌的所有者
            isApprovedForAll[ownerOf[id]][msg.sender]);     //所有不可替代的代币都将出售
        emit Approval(ownerOf[id], getApproved[id] = to, id);

    }

    //所有不可替代的代币都将出售
    function setApprovalForAll(address to, bool bol) external {

        emit ApprovalForAll(msg.sender, to, isApprovedForAll[msg.sender][to] = bol);

    }

    //省略，因为它具有相同的功能
    function safeTransferFrom(address from, address to, uint id) external {

        transferFrom(from, to, id); 

    }

    //省略，因为它具有相同的功能
    function safeTransferFrom(address from, address to, uint id, bytes memory) external {

        transferFrom(from, to, id); 

    }

    //实际传递函数
    function transferFrom(address from, address to, uint id) public{

        unchecked{

            assert(ownerOf[id] == from ||                               //必须是所有者或
                getApproved[id] == to ||                                //已被授权或
                isApprovedForAll[ownerOf[id]][from] ||                  //待全部出售或
                access[msg.sender] > 0);                                //有管理员权限
            
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
    function tokensOwned(address addr)external view returns(uint[]memory) {

        return enumBalance[addr];

    }

    //通过将令牌转移到0x地址来销毁代币
    function burn(uint id) external {

        transferFrom(ownerOf[id], address(0), id);

    }

    //the is token creation function 可用于转移和铸币
    function transfer(address from, address to, uint id) private {

        unchecked {

            require(suspended == 0, "Contract is suspended");                           //合约未被暂停

            if(address(iProxy) != address(0))
                require(IDID(iProxy.addrs(3)).uintData(from, 0) == 0 &&                 //发件人不能被列入黑名单
                    IDID(iProxy.addrs(3)).uintData(to, 0) == 0, "User is blacklisted"); //接收者也不能被列入黑名单

            if (to != address(0)) {

                enumBalance[msg.sender].push(id);                                       //添加到新的所有者数组
                ++balanceOf[to];                                                        //添加当前所有者的余额
                                                                    
            }

            emit Approval(ownerOf[id], ownerOf[id] = to, id);
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
            if (price > 0) {

                //如果不指定地址，则转入主币，否则从合约地址转入
                if (contAddr == address(0)) {

                    require(msg.value >= price, "Insufficient amount");
                    payable(owner).transfer(address(this).balance);

                } else {

                    require(IERC20(contAddr).transfer(address(this), price), "Insufficient amount");
                    IERC20(contAddr).transfer(owner, price);

                }

            }

            //如果新令牌使用count，否则使用代币id
            uint num = id > 0 ? id : count++;

            //检查签名和更新指数
            check(addr, v, r, s);
            
            //设置代币的统一资源标识符
            tokenURI[num] = uri;

            //铸币
            transfer(address(this), addr, num);

        }

    }

    //根据合约类型和级别设置定价
    function setLevel(uint _level, address contAddr, uint price) external OnlyAccess {

        Level storage lv = level[_level];
        lv.contAddr = contAddr;
        lv.price = price;

    }

}