// SPDX-License-Identifier: None
pragma solidity ^0.8.18;

import "./UUPS.sol";

contract Pizza is Initializable, UUPSUpgradeable {
   uint public slices;

   function initialize(uint _sliceCount) external initializer {
       slices = _sliceCount;
       __Ownable_init();
   }

   function eatSlice() virtual external {
       require(slices > 1, "no slices left");
       slices -= 1;
   }
}

contract PizzaV2 is Pizza {
   function refillSlice() external {
       slices += 1;
   }
   function pizzaVersion() external pure returns (uint) {
       return 2;
   }
   function eatSlice() external override {
       require(slices > 0, "no slices left");
       slices -= 1;
   }
}