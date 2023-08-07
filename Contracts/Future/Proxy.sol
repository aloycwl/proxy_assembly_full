// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import "./UUPS.sol";

contract NFTExample is UUPSUpgradeable {
   uint public totalSupply;
   string public name;

   function initialize(uint totalSupply_) external init {
       (totalSupply, name) = (totalSupply_, "Crazy NFT");
   }
   function mint() virtual external {
       require(totalSupply-- > 0x1, "Ran out of supply");
   }
}

contract NFTExampleV2 is NFTExample {
   function NFTVersion() external pure returns (uint) {
       return 0x2;
   }
   function newNFT() external {
       totalSupply += 0xf;
       name = "Wild NFT";
   } 
   function mint() external override {
       require(totalSupply-- > 0x0, "Ran out of supply");
   }
}