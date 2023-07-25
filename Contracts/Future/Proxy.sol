// SPDX-License-Identifier: None
pragma solidity ^0.8.18;

import "./UUPS.sol";

// gas: 1159850
contract Pizza is UUPSUpgradeable {
   uint public slices;
   string public shopName;

   function initialize(uint _sliceCount) external init {
       slices = _sliceCount;
       shopName = "Pizza Hut";
       owner = msg.sender;
   }
   function eatSlice() virtual external {
       require(slices-- > 1, "no slices left");
   }
}

// gas: 1208029
contract PizzaV2 is Pizza {
   function pizzaVersion() external pure returns (uint) {
       return 2;
   }
   function newShop() external {
       slices+=24;
       shopName = "Domino";
   } 
   function eatSlice() external override {
       require(slices-- > 0, "no slices left");
   }
}