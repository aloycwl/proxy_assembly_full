pragma solidity 0.8.19;//SPDX-License-Identifier:None

interface IERC20{
    function transfer(address,uint)external returns(bool);
}

interface GE{
    function score(address)external view returns(uint);
    function setScore(address, uint)external;
    function withdrawal(address, uint)external;
}

contract GameEngineProxy is GE{
    GE public m;
    address private _owner;
    constructor(address a, bytes32 b){
        _owner = msg.sender;
        m = GE(address(new GameEngine(a, b)));
    }
    function score(address a)external view returns(uint){ return m.score(a); }
    function setScore(address a, uint b)external{ m.setScore(a, b); }
    function withdrawal(address a, uint b)external{ m.withdrawal(a, b); }
    
    function NewAddress(address a)external{
        require(msg.sender == _owner);
        m = GE(a);
    }
}

contract GameEngine{
    IERC20 erc20;
    bytes32 private key;
    mapping(address=>uint)public score;
    mapping(address => bool)public _access;
    modifier OnlyAccess(){
        require(_access[msg.sender]); _;
    }

    constructor(address a, bytes32 b){
        (_access[msg.sender], erc20, key) = (true, IERC20(a), b);
    }

    function UpdateTokenAddress(address a)external OnlyAccess{
        erc20 = IERC20(a);
    }
    function UpdateKey(bytes32 a)external OnlyAccess{
        key = a;
    }
    function setScore(address a, uint b)external{
        
        score[a]+=b;
    }
    function withdrawal(address a, uint b)external{
        erc20.transfer(a,b);
    }
}