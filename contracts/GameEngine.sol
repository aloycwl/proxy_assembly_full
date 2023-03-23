pragma solidity 0.8.19;//SPDX-License-Identifier:None

interface IERC20{
    function transfer(address,uint)external returns(bool);
}

contract GameEngine{
    IERC20 erc20;
    
    mapping(address=>uint)public score;

    function setTokenAddress(address addr)external{
        erc20 = IERC20(addr);
    }
    function setScore(uint amt)external{
        score[msg.sender]+=amt;
    }
    function withdrawal(uint amt)external{
        erc20.transfer(msg.sender,amt);
    }
}