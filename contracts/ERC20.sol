pragma solidity 0.8.19;//SPDX-License-Identifier:None

struct User{
    uint bal;
    mapping(address => uint)allow;
    bool blocked;
}

contract ERC20AC{
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    bool public Suspended;
    uint public totalSupply = 1e24;
    uint public constant decimals = 18;
    string public constant symbol = "WD";
    string public constant name = "Wild Dynasty";
    mapping(address => User)public u;
    mapping(address => bool)public _access;
    modifier OnlyAccess(){
        require(_access[msg.sender]); _;
    }
    /*
    Standard functions for ERC20
    ERC20基本函数 
    */
    constructor(){
        _access[msg.sender] = true;
        emit Transfer(address(this), msg.sender, u[msg.sender].bal=totalSupply);
    }
    function balanceOf(address addr)external view returns(uint){
        require(!u[addr].blocked, "Suspended");
        return u[addr].bal;
    }
    function allowance(address addr_a, address addr_b)external view returns(uint){
        return u[addr_a].allow[addr_b];
    }
    function approve(address a, uint b)external returns(bool){
        u[msg.sender].allow[a] = b;
        emit Approval(msg.sender, a, b);
        return true;
    }
    function transfer(address a, uint b)external returns(bool){
        return transferFrom(msg.sender, a, b);
    }
    function transferFrom(address a, address b, uint c)public returns(bool){unchecked{
        (User storage sender, User storage recipient) = (u[a], u[b]);
        require(sender.bal >= c, "Insufficient balance");
        require(a == msg.sender || sender.allow[b] >= c, "Insufficient allowance");
        require(!Suspended && !sender.blocked, "Suspended");
        if(sender.allow[b] >= c) sender.allow[b] -= c;
        (sender.bal -= c, recipient.bal += c);
        emit Transfer(a, b, c);
        return true;
    }}
    /*
    Custom functions
    自定函数
    */
    function SetAccess(address a, bool b)external OnlyAccess{
        _access[a] = b;
    }
    function ToggleSuspend()external OnlyAccess{
        Suspended = Suspended ? false : true;
    }
    function ToggleBlock(address addr)external OnlyAccess{
        u[addr].blocked = !u[addr].blocked;
    }
    function Burn(uint amt)external OnlyAccess{unchecked{
        require(u[msg.sender].bal >= amt, "Insufficient balance");
        transferFrom(msg.sender, address(0), amt);
        totalSupply -= amt;
    }}
}
