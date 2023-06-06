//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Util.sol";
import "./Interfaces.sol";

//代币合约
contract ERC20 is IERC20, Util {

    //ERC20标准变量 
    uint public totalSupply;
    uint public constant decimals = 18;
    string public symbol;
    string public name;
    mapping(address => mapping (address => uint)) public allowance;

    //ERC20自定变量 
    uint public suspended;
    IDID public iDID;

    //ERC20标准函数 
    constructor(address proxy, address receiver, uint amt, string memory _name, string memory _sym) {

        (iDID, name, symbol) = (IDID(IProxy(proxy).addrs(3)), _name, _sym);     //调用交叉合约函数
        mint(amt, receiver);                                                    //铸造给定地址的代币数量

    }

    function balanceOf(address addr) public view returns (uint) {

        return iDID.uintData(addr, 3);

    }

    function approve(address to, uint amt) external returns (bool) {

        emit Approval(msg.sender, to, allowance[msg.sender][to] = amt);
        return true;

    }

    function transfer(address to, uint amt) external returns (bool) {

        return transferFrom(msg.sender, to, amt);

    }

    function transferFrom(address from, address to, uint amt) public returns (bool) {

        unchecked {                                                             //使用assert而不是require来节省燃料

            assert(balanceOf(from) >= amt);                                     //地址必须有足够的代币才能转账
            assert(from == msg.sender || allowance[from][to] >= amt);           //必须是地址所有者或接收者已获得授权
            assert(iDID.uintData(from, 0) == 0 && iDID.uintData(to, 0) == 0);   //发件和接收者不能被列入黑名单
            assert(suspended == 0);                                             //合约未被暂停
            
            if(allowance[from][to] >= amt) allowance[from][to] -= amt;          //如果有授权，相应地去除

            iDID.updateUint(from, 3, balanceOf(from) - amt);                    //3号是ERC20代币1的合约
            iDID.updateUint(from, 3, balanceOf(to) + amt);            
            emit Transfer(from, to, amt);                                       //发出日志
            return true;

        }

    }

    //切换暂停
    function toggleSuspend() external OnlyAccess {

        suspended = suspended == 0 ? 1 : 0;

    }

    //铸币代币，只允许有访问权限的地址
    function mint(uint amt, address addr) public OnlyAccess {

        unchecked {

            totalSupply += amt;                                 //将数量添加到用户和总供应量
            iDID.updateUint(addr, 3, balanceOf(addr) + amt);    //3号是ERC20代币1的合约
            emit Transfer(address(this), addr, amt);            //发出日志

        }

    }

    //烧毁代币，任何人都可以烧毁
    function burn(uint amt) external {

        unchecked {

            assert(balanceOf(msg.sender) >= amt);               //燃烧者必须有足够的代币
            transferFrom(msg.sender, address(0), amt);          //调用标准函数
            totalSupply -= amt;                                 //减少总供应

        }

    }
    
}