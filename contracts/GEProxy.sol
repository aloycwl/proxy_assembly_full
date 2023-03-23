pragma solidity 0.8.19;//SPDX-License-Identifier:None

interface GE{
    function setTokenAddress(address addr)external;
    function setScore(uint amt)external;
    function withdrawal(uint amt)external;
}

contract GameEngine{
    GE m;
    address private _owner;

    constructor(address a){
        (m, _owner) = (GE(a), msg.sender);
    }
    mapping(address=>uint)public score;

    function setTokenAddress(address a)external{ m.setTokenAddress(a); }
    function setScore(uint a)external{ m.setScore(a); }
    function withdrawal(uint a)external{ m.withdrawal(a); }
}