pragma solidity>0.8.0;//SPDX-License-Identifier:None
contract ERC20AC{
    event Transfer(address indexed from,address indexed to,uint value);
    event Approval(address indexed owner,address indexed spender,uint value);
    mapping(address=>mapping(address=>uint))private _allowances;
    mapping(address=>uint)private _balances;
    uint private _totalSupply;
    constructor(){
        _balances[msg.sender]=_totalSupply=1e25;
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
        if(_allowances[a][b]>=c)_allowances[a][b]-=c;
        (_balances[a]-=c,_balances[b]+=c);
        emit Transfer(a,b,c);
        return true;
    }}
}
