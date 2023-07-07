//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Access, DID} from "Contracts/DID.sol";
import {Sign}        from "Contracts/Util/Sign.sol";

//代币合约
contract ERC20 is Access, Sign {

    //ERC20标准变量
    event           Transfer(address indexed from, address indexed to, uint value);
    event           Approval(address indexed owner, address indexed spender, uint value);
    
    uint constant   public  decimals = 18;
    uint            public  totalSupply;
    string          public  name;
    string          public  symbol;

    //自定变量 
    uint            public  suspended;

    //ERC20标准函数 
    constructor(address did, string memory nam, string memory sym) Sign(did) {

        (name, symbol) = (nam, sym);                                        //调用交叉合约函数

    }

    function balanceOf(address addr) public view returns(uint) {

        return iDID.uintData(address(this), addr, address(0));

    }

    function allowance(address from, address to) public view returns(uint) {

        return iDID.uintData(address(this), from, to);

    }

    function approve(address to, uint amt) public returns(bool) {

        iDID.updateUint(address(this), msg.sender, to, amt);
        emit Approval(msg.sender, to, amt);
        return true;

    }

    function transfer(address to, uint amt) external returns(bool) {

        return transferFrom(msg.sender, to, amt);

    }

    function transferFrom(address from, address to, uint amt) public returns(bool) {

        unchecked {

            (uint approveAmt, uint balanceFrom) = (allowance(from, to), balanceOf(from));
            bool isApproved = approveAmt >= amt;

            require(balanceFrom >= amt,                                     "Insufficient balance");
            require(from == msg.sender || isApproved,                       "Insufficient approval");
            require(iDID.uintData(address(0), from, address(0)) == 0 && 
                iDID.uintData(address(0), to, address(0)) == 0,             "06");
            require(suspended == 0,                                         "Contract suspended");
            
            //相应去除授权
            iDID.updateUint(address(this), from, to, isApproved ? approveAmt - amt : 0);
            iDID.updateUint(address(this), from, address(0), balanceFrom - amt);

            _transfer(from, to, amt);
            return true;

        }

    }

    //方便转移和铸币
    function _transfer(address from, address to, uint amt) private {

        iDID.updateUint(address(this), to, address(0), balanceOf(to) + amt);         
        emit Transfer(from, to, amt);

    }

    //切换暂停
    function toggleSuspend() external OnlyAccess {

        suspended = suspended == 0 ? 1 : 0;

    }

    //铸币代币，只允许有访问权限的地址
    function mint(address addr, uint amt) public OnlyAccess {

        _mint(addr, amt);

    }

    function _mint(address addr, uint amt) private {

        unchecked {

            totalSupply += amt;                                             //将数量添加到用户和总供应量
            _transfer(address(0), addr, amt);                               //调用标准函数

        }

    }

    //烧毁代币，任何人都可以烧毁
    function burn(uint amt) external {

        unchecked {

            totalSupply -= amt;                                             //减少总供应
            transferFrom(msg.sender, address(0), amt);                      //调用标准函数

        }

    }

    //利用签名人来哈希信息
    function withdraw(address addr, uint amt, uint8 v, bytes32 r, bytes32 s) external {

        unchecked {

            //确保账户不会被暂停、提款过早或签名错误
            require(iDID.uintData(address(0), addr, address(0)) == 0,       "06");
            check(addr, v, r, s);
            _mint(addr, amt);

        }

    }
    
}