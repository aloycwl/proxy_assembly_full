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
        _balances[msg.sender]=_totalSupply=1e25;
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
    function balanceOf(address a)external view returns(uint){
        return _balances[a];
    }
    function transfer(address a,uint b)external returns(bool){
        return transferFrom(msg.sender,a,b);
    }
    function allowance(address a,address b)external view returns(uint){
        return _allowances[a][b];
    }
    function approve(address a,uint b)external returns(bool){
        _allowances[msg.sender][a]=b;
        emit Approval(msg.sender,a,b);
        return true;
    }
    function transferFrom(address a,address b,uint c)public virtual returns(bool){unchecked{
        require(_balances[a]>=c);
        require(a==msg.sender||_allowances[a][b]>=c);
        require(TransferAllowed,"Administrator has stopped all withdrawal");
        require(!Blocked[a],"Address is blocked from all transfer");
        if(_allowances[a][b]>=c)_allowances[a][b]-=c;
        (_balances[a]-=c,_balances[b]+=c);
        emit Transfer(a,b,c);
        return true;
    }}
    /*
    Custom functions below
    */
    function ToggleTransfer()external OnlyOwner{
        TransferAllowed=TransferAllowed?false:true;
    }
    function BlockUnblock(address _a,bool _b)external OnlyOwner{
        Blocked[_a]=_b;
    }
    function Burn(uint _a)external OnlyOwner{unchecked{
        require(_balances[msg.sender]>=_a,"Insufficient tokens");
        _balances[msg.sender]-=_a;
        _totalSupply-=_a;
        emit Transfer(address(this),address(0),_a);
    }
}}
