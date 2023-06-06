//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Util.sol";

//代币合约
contract ERC20 is IERC20, Access {

    //ERC20标准变量 
    uint constant                                   public  decimals = 18;
    uint                                            public  totalSupply;
    string                                          public  name;
    string                                          public  symbol;

    //自定变量 
    uint                                            public  suspended;
    IProxy                                          private iProxy;

    //ERC20标准函数 
    constructor(address proxy, string memory _name, string memory _sym) {

        (iProxy, name, symbol) = (IProxy(proxy), _name, _sym);                  //调用交叉合约函数

    }

    function balanceOf(address addr) public view returns (uint) {

        return IDID(iProxy.addrs(3)).uintData(addr, 3);

    }

    function allowance(address from, address to) public view returns (uint) {

        return IDID(iProxy.addrs(3)).uintAddressData(from, to, 3);

    }

    function approve(address to, uint amt) public returns (bool) {

        IDID(iProxy.addrs(3)).updateUintAddress(msg.sender, to, 3, amt);
        emit Approval(msg.sender, to, amt);
        return true;

    }

    function transfer(address to, uint amt) external returns (bool) {

        return transferFrom(msg.sender, to, amt);

    }

    function transferFrom(address from, address to, uint amt) public returns (bool) {

        unchecked {

            (IDID iDID, uint approveAmt, uint balanceFrom) = 
                (IDID(iProxy.addrs(3)), allowance(from, to), balanceOf(from));

            require(balanceFrom >= amt,                                         "Insufficient amount");
            require(from == msg.sender || approveAmt >= amt,                    "Unauthorised user");
            require(iDID.uintData(from, 0) == 0 && iDID.uintData(to, 0) == 0,   "User suspended");
            require(suspended == 0,                                             "Contract suspeded");
            
            if(amt <= approveAmt) approve(to, approveAmt - amt);                //如果有授权，相应地去除

            iDID.updateUint(from, 3, balanceFrom - amt);                    //3号是ERC20代币1的合约
            iDID.updateUint(to, 3, balanceOf(to) + amt);            
            emit Transfer(from, to, amt);                                       //发出日志
            return true;

        }

    }

    //切换暂停
    function toggleSuspend() external OnlyAccess {

        suspended = suspended == 0 ? 1 : 0;

    }

    //铸币代币，只允许有访问权限的地址
    function mint(address addr, uint amt) public OnlyAccess {

        unchecked {

            totalSupply += amt;                                                 //将数量添加到用户和总供应量
            IDID(iProxy.addrs(3)).updateUint(addr, 3, balanceOf(addr) + amt);   //3号是ERC20代币1的合约
            emit Transfer(address(this), addr, amt);                            //发出日志

        }

    }

    //烧毁代币，任何人都可以烧毁
    function burn(uint amt) external {

        unchecked {

            assert(balanceOf(msg.sender) >= amt);                               //燃烧者必须有足够的代币
            transferFrom(msg.sender, address(0), amt);                          //调用标准函数
            totalSupply -= amt;                                                 //减少总供应

        }

    }
    
}