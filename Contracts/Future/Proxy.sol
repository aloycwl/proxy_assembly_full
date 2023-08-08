// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import "./UUPS.sol";

contract NFTExample is UUPSUpgradeable {

    uint public totalSupply;

    function initialize(uint totalSupply_) external {
        init();
        totalSupply = totalSupply_;
    }

    function mint() virtual external {
        require(totalSupply-- > 0x1, "Ran out of supply");
    }

    function name() virtual external pure returns (string memory) {
        return "Crazy NFT";
    }
}

contract NFTExampleV2 is NFTExample {
    uint constant public NFTVersion = 0x02;

    function newNFT() external {
        totalSupply += 0x0f;
        
    } 

    function mint() external override {
        require(totalSupply-- > 0x00, "Ran out of supply");
    }

    function name() override external pure returns (string memory) {
        return "Wild NFT";
    }
}