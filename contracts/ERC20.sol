pragma solidity>0.8.0;//SPDX-License-Identifier:None

struct User{
    uint bal;
    mapping(address=>uint)allow;
    bool blocked;
}

contract ERC20AC{
    event Transfer(address indexed from,address indexed to,uint value);
    event Approval(address indexed owner,address indexed spender,uint value);
    bool public Suspended;
    uint public constant decimals=18;
    uint public totalSupply=1e24;
    string public constant symbol="WD";
    string public constant name="Wild Dynasty";
    mapping(address=>User)public u;
    mapping(address=>bool)private _access;
    modifier OnlyAccess(){
        require(_access[msg.sender]);_;
    }

    /*
    Standard functions for ERC20
    ERC20基本函数 
    */
    constructor(){
        _access[msg.sender]=true;
        emit Transfer(address(this),msg.sender,u[msg.sender].bal=totalSupply);
    }
    function balanceOf(address addr)external view returns(uint){
        require(!u[addr].blocked,"Suspended");
        return u[addr].bal;
    }
    function transfer(address addr,uint amt)external returns(bool){
        return transferFrom(msg.sender,addr,amt);
    }
    function allowance(address addr_a,address addr_b)external view returns(uint){
        return u[addr_a].allow[addr_b];
    }
    function approve(address addr,uint amt)external returns(bool){
        u[msg.sender].allow[addr]=amt;
        emit Approval(msg.sender,addr,amt);
        return true;
    }
    function transferFrom(address from,address to,uint amt)public returns(bool){unchecked{
        (User storage sender, User storage recipient) = (u[from], u[to]);
        require(sender.bal >= amt, "Insufficient balance");
        require(from == msg.sender || sender.allow[to] >= amt, "Insufficient allowance");
        require(!Suspended && !sender.blocked, "Suspended");
        if (from != msg.sender) sender.allow[to] -= amt;
        (sender.bal -= amt, recipient.bal += amt);
        emit Transfer(from, to, amt);
        return true;
    }}

    /*
    Custom functions
    自定函数
    */
    function ToggleSuspend()external OnlyAccess{
        Suspended=Suspended?false:true;
    }
    function ToggleBlock(address addr)external OnlyAccess{
        u[addr].blocked=!u[addr].blocked;
    }
    function Burn(uint amt)external OnlyAccess{unchecked{
        require(u[msg.sender].bal>=amt,"Insufficient balance");
        transferFrom(msg.sender,address(0),amt);
        totalSupply-=amt;
    }}
}
