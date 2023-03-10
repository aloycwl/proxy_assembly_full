pragma solidity>0.8.0;//SPDX-License-Identifier:None
contract ERC20AC{
    event Transfer(address indexed from,address indexed to,uint value);
    event Approval(address indexed owner,address indexed spender,uint value);
    mapping(address=>mapping(address=>uint))private _allowances;
    mapping(address=>uint)private _balances;
    uint private _totalSupply;

    address private _owner;
    bool public TransferAllowed=true;
    mapping(address=>bool)public Blocked;
    modifier OnlyOwner(){
        require(_owner==msg.sender);_;
    }

    constructor(){
        _owner=msg.sender;
        _balances[msg.sender]=_totalSupply=1e24;
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
        return _balances[addr];
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
        require(_balances[from]>=amt,"Insufficient balance");
        require(from==msg.sender||_allowances[from][to]>=amt,"Insufficent allowance");
        require(TransferAllowed,"Administrator has stopped all withdrawal");
        require(!Blocked[from],"Address is blocked from all transfer");
        if(_allowances[from][to]>=amt)_allowances[from][to]-=amt;
        (_balances[from]-=amt,_balances[to]+=amt);
        emit Transfer(from,to,amt);
        return true;
    }}
    /*
    Custom functions below
    */
    function ToggleTransfer()external OnlyOwner{
        TransferAllowed=TransferAllowed?false:true;
    }
    function BlockUnblock(address addr,bool status)external OnlyOwner{
        Blocked[addr]=status;
    }
    function Burn(uint amt)external OnlyOwner{unchecked{
        require(_balances[msg.sender]>=amt,"Insufficient balance");
        _balances[msg.sender]-=amt;
        _totalSupply-=amt;
        emit Transfer(address(this),address(0),amt);
    }
}}
