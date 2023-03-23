pragma solidity 0.8.19;//SPDX-License-Identifier:None

interface IERC20{
    function transfer(address,uint)external returns(bool);
}

contract GameEngine{
    IERC20 erc20;
    
    mapping(address=>uint)public score;

    function setTokenAddress(address a)external{
        erc20 = IERC20(a);
    }
    function setScore(address a, uint b)external{
        score[a]+=b;
    }
    function withdrawal(address a, uint b)external{
        erc20.transfer(a,b);
    }
}