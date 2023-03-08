/*
This just simulate the smart contract for the game to store information
Tokens will also be stored in this contract for players to extract out
*/

pragma solidity>0.8.0;//SPDX-License-Identifier:None

interface Ierc20{
    function transfer(address,uint)external returns(bool);
}

contract GameEngine{
    Ierc20 erc20;
    mapping(address=>uint)public score;

    function setTokenAddress(address addr)external{
        erc20 = Ierc20(addr);
    }
    function setScore(uint amt)external{
        score[msg.sender]+=amt;
    }
    function getScore()external view returns(uint){
        return score[msg.sender];
    }
    function withdrawal(uint amt)external{
        erc20.transfer(msg.sender,amt);
    }
}