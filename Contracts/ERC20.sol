//SPDX-License-Identifier:None
pragma solidity ^0.8.0;

import "Contracts/Util/Access.sol";
import "Contracts/Proxy.sol";
import "Contracts/DID.sol";

//代币合约
contract ERC20 is Access {

    //ERC20标准变量
    event           Transfer (address indexed from, address indexed to, uint value);
    event           Approval (address indexed owner, address indexed spender, uint value);
    
    uint constant   public  decimals = 18;
    uint            public  totalSupply;
    string          public  name;
    string          public  symbol;

    //自定变量 
    uint            public  suspended;
    Proxy           private iProxy;

    //ERC20标准函数 
    constructor (address proxy, string memory _name, string memory _sym) {

        (iProxy, name, symbol) = (Proxy(proxy), _name, _sym);                  //调用交叉合约函数

    }

    function balanceOf (address addr) public view returns (uint) {

        return DID(iProxy.addrs(3)).uintData(address(this), addr, address(0));

    }

    function allowance (address from, address to) public view returns (uint) {

        return DID(iProxy.addrs(3)).uintData(address(this), from, to);

    }

    function setAllowance (address from, address to, uint amt) private {

        DID(iProxy.addrs(3)).updateUint(address(this), from, to, amt);
        emit Approval(from, to, amt);

    }

    function approve (address to, uint amt) public returns (bool) {

        setAllowance(msg.sender, to, amt);
        return true;

    }

    function transfer (address to, uint amt) external returns (bool) {

        return transferFrom(msg.sender, to, amt);

    }

    function transferFrom (address from, address to, uint amt) public returns (bool) {

        unchecked {

            (DID iDID, uint approveAmt, uint balanceFrom) = 
                (DID(iProxy.addrs(3)), allowance(from, to), balanceOf(from));
            bool isApproved = approveAmt >= amt;

            require(balanceFrom >= amt,                                         "Insufficient amount");
            require(from == msg.sender || isApproved,                           "Unauthorised amount");
            require(iDID.uintData(address(0), from, address(0)) == 0 && 
                iDID.uintData(address(0), to, address(0)) == 0,                 "User suspended");
            require(suspended == 0,                                             "Contract suspeded");
            
            setAllowance(from, to, isApproved ? approveAmt - amt : 0);          //如果有授权，相应地去除
            iDID.updateUint(address(this), from, address(0), balanceFrom - amt);
            iDID.updateUint(address(this), to, address(0), balanceOf(to) + amt);            
            emit Transfer(from, to, amt);                                       //发出日志
            return true;

        }

    }

    //切换暂停
    function toggleSuspend () external OnlyAccess {

        suspended = suspended == 0 ? 1 : 0;

    }

    //铸币代币，只允许有访问权限的地址
    function mint (address addr, uint amt) public OnlyAccess {

        unchecked {

            totalSupply += amt;                                                 //将数量添加到用户和总供应量
            DID(iProxy.addrs(3)).updateUint(address(this), addr, address(0), balanceOf(addr) + amt);
            emit Transfer(address(this), addr, amt);                            //发出日志

        }

    }

    //烧毁代币，任何人都可以烧毁
    function burn (uint amt) external {

        unchecked {

            assert(balanceOf(msg.sender) >= amt);                               //燃烧者必须有足够的代币
            transferFrom(msg.sender, address(0), amt);                          //调用标准函数
            totalSupply -= amt;                                                 //减少总供应

        }

    }
    
}