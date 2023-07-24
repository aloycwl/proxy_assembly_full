// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./UUPS.sol";

contract Pizza is Initializable, UUPSUpgradeable, OwnableUpgradeable {
   uint256 public slices;

   function initialize(uint256 _sliceCount) public initializer {
       slices = _sliceCount;
       __Ownable_init();
   }

   function _authorizeUpgrade(address) internal override onlyOwner {}

   function eatSlice() external {
       require(slices > 1, "no slices left");
       slices -= 1;
   }
}