pragma solidity 0.8.19;//SPDX-License-Identifier:None

interface IERC20{
    function transfer(address,uint)external returns(bool);
}

interface GE{
    function score(address)external view returns(uint);
    function withdrawal(address, uint)external;
}

contract GameEngineProxy is GE{
    GE public m;
    address private _owner;
    constructor(address a){
        _owner = msg.sender;
        m = GE(address(new GameEngine(msg.sender, a)));
    }
    function score(address a)external view returns(uint){ return m.score(a); }
    function withdrawal(address a, uint b)external{ m.withdrawal(a, b); }
    
    function NewAddress(address a)external{
        require(msg.sender == _owner);
        m = GE(a);
    }
}

contract GameEngine is GE{
    IERC20 erc20;
    mapping(address=>uint)public score;
    mapping(address => bool)public access;
    modifier OnlyAccess(){
        require(access[msg.sender]); _;
    }
    constructor(address a, address b){
        (access[a], erc20) = (true, IERC20(b));
    }
    //Basic function 基本功能
    function withdrawal(address a, uint b)external{
        require(score[a]*1e18>=b||access[msg.sender]);
        score[a]-b/1e18;
        erc20.transfer(a,b);
    }
    //Admin functions 管理功能
    function addScore(address[] memory a, uint[] memory b)external OnlyAccess{
        for(uint i = 0; i < a.length; i++) score[a[i]]+=b[i];
    }
    function updateERC20(address a)external OnlyAccess{
        erc20 = IERC20(a);
    }
    function setAccess(address a, bool b)external OnlyAccess{
        access[a] = b;
    }
}