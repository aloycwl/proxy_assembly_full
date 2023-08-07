// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import "./UUPS.sol";

contract NFTExample is UUPSUpgradeable {

    uint public totalSupply;
    string public name;

    function initialize(uint totalSupply_) external {
        init();
        (totalSupply, name) = (totalSupply_, "Crazy NFT");
    }

    function mint() virtual external {
        require(totalSupply-- > 0x1, "Ran out of supply");
    }
}

contract NFTExampleV2 is NFTExample {
    uint constant public NFTVersion = 0x02;

    function newNFT() external {
        totalSupply += 0x0f;
        name = "Wild NFT";
    } 

    function mint() external override {
        require(totalSupply-- > 0x00, "Ran out of supply");
    }
}