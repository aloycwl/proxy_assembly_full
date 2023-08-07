// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import "./UUPS.sol";

contract NFTExample is UUPSUpgradeable {
   uint public totalSupply;
   string public name = "Crazy NFT";

   function initialize(uint totalSupply_) external init {
       totalSupply = totalSupply_;
       owner = msg.sender;
   }
   function mint() virtual external {
       require(totalSupply-- > 1, "Ran out of supply");
   }
}

contract NFTExampleV2 is NFTExample {
   function NFTVersion() external pure returns (uint) {
       return 2;
   }
   function newNFT() external {
       totalSupply += 24;
       name = "Wild NFT";
   } 
   function mint() external override {
       require(totalSupply-- > 0, "Ran out of supply");
   }
}