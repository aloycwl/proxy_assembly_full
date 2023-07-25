// SPDX-License-Identifier: None
pragma solidity ^0.8.18;

import "./UUPS.sol";

// gas: 1159850
contract Pizza is UUPSUpgradeable {
   uint public slices;

   function initialize(uint _sliceCount) external {
       slices = _sliceCount;
       owner = msg.sender;
   }

   function eatSlice() virtual external {
       require(slices-- > 1, "no slices left");
   }
}

// gas: 1208029
contract PizzaV2 is Pizza {
   function refillSlice() external {
       ++slices;
   }
   function pizzaVersion() external pure returns (uint) {
       return 2;
   }
   function eatSlice() external override {
       require(slices-- > 0, "no slices left");
   }
}