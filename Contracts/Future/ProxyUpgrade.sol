// SPDX-License-Identifier: None
pragma solidity ^0.8.18;

import "Contracts/Future/Proxy.sol";

contract PizzaV2 is Pizza {
   function refillSlice() external {
       slices += 1;
   }
   function pizzaVersion() external pure returns (uint) {
       return 2;
   }
}