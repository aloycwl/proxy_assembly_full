pragma solidity>0.8.0;//SPDX-License-Identifier:None
contract ERC20AC{
    event Transfer(address indexed from,address indexed to,uint value);
    event Approval(address indexed owner,address indexed spender,uint value);

    mapping(address=>mapping(address=>uint))private _allowances;
    //mapping(address=>uint)private _balances;
    //mapping(address=>bool)public Blocked;

    uint private _totalSupply;
    address private _owner;
    bool public Suspended;

    struct User{
        uint bal;
        mapping(address=>uint)allow;
        bool blocked;
    }
    mapping(address=>User)public u;
    modifier OnlyOwner(){
        require(_owner==msg.sender);_;
    }

    /*
    Standard functions for ERC20
    ERC20基本函数 
    */
    constructor(){
        _owner=msg.sender;
        u[msg.sender].bal=_totalSupply=1e24;
        emit Transfer(address(this),msg.sender,_totalSupply);
    }
    function name()external pure returns(string memory){
        return "Wild Dynasty";
    }
    function symbol()external pure returns(string memory){
        return "WD";
    }
    function decimals()external pure returns(uint){
        return 18;
    }
    function totalSupply()external view returns(uint){
        return _totalSupply;
    }
    function balanceOf(address addr)external view returns(uint){
        require(!u[addr].blocked,"Suspended");
        return u[addr].bal;
    }
    function transfer(address addr,uint amt)external returns(bool){
        return transferFrom(msg.sender,addr,amt);
    }
    function allowance(address addr_a,address addr_b)external view returns(uint){
        return _allowances[addr_a][addr_b];
    }
    function approve(address addr,uint amt)external returns(bool){
        _allowances[msg.sender][addr]=amt;
        emit Approval(msg.sender,addr,amt);
        return true;
    }
    function transferFrom(address from,address to,uint amt)public virtual returns(bool){unchecked{
        require(u[from].bal>=amt,"Insufficient balance");
        require(from==msg.sender||_allowances[from][to]>=amt,"Insufficent allowance");
        require(!Suspended&&!u[from].blocked,"Suspended");
        if(_allowances[from][to]>=amt)_allowances[from][to]-=amt;
        (u[from].bal-=amt,u[to].bal+=amt);
        emit Transfer(from,to,amt);
        return true;
    }}

    /*
    Custom functions
    自定函数
    */
    function ToggleSuspend()external OnlyOwner{
        Suspended=Suspended?false:true;
    }
    function ToggleBlock(address addr)external OnlyOwner{
        u[addr].blocked=!u[addr].blocked;
    }
    function Burn(uint amt)external OnlyOwner{unchecked{
        require(u[_owner].bal>=amt,"Insufficient balance");
        u[_owner].bal-=amt;
        _totalSupply-=amt;
        emit Transfer(address(this),address(0),amt);
    }
}}
