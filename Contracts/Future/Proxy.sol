// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// Open Zeppelin libraries for controlling upgradability and access.
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

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