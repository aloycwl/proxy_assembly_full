pragma solidity 0.8.19;//SPDX-License-Identifier:None

interface GE{
    function setTokenAddress(address)external;
    function setScore(address, uint)external;
    function withdrawal(address, uint)external;
}

contract GameEngine{
    GE m;
    address private _owner;
    constructor(address a){
        (m, _owner) = (GE(a), msg.sender);
    }
    function setTokenAddress(address a)external{ m.setTokenAddress(a); }
    function setScore(address a, uint b)external{ m.setScore(a, b); }
    function withdrawal(address a, uint b)external{ m.withdrawal(a, b); }

    function NewAddress(address a)external{
        require(msg.sender == _owner);
        m = GE(a);
    }
}