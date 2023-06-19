//SPDX-License-Identifier:None
pragma solidity ^0.8.0;

import "Contracts/Util/Access.sol";

contract NFTMarketData is Access {

    uint public fee;

    //设置费用
    function setFee (uint amt) external OnlyAccess {

        fee = amt;

    }

}