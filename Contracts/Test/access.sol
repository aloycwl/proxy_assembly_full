//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Access} from "Contracts/Util/Access.sol";

contract test1 is Access{
    uint i;

    function addI() external OnlyAccess() {
        i++;
    }
}

contract test2 {
    test1 t;

    function test(address a) external {
        test1(a).addI();
    }
}