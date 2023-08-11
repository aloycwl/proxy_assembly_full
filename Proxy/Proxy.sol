// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {UUPSUpgradeable} from "./UUPS.sol";

contract NFTExample is UUPSUpgradeable {

    uint public totalSupply;
    string public name;

    function initialize(uint totalSupply_) external {
        init();
        (totalSupply, name) = (totalSupply_, "Crazy NFT");
    }

    function mint() external virtual {
        require(totalSupply-- > 0x1, "Ran out of supply");
    }
}

contract NFTExampleV2 is NFTExample {

    uint constant public NFTVersion = 0x02;

    constructor() {
        name = "Wild NFT";
    }

    function addSupply() external {
        totalSupply += 0x0f;
    } 

    function mint() external override {
        require(totalSupply-- > 0x00, "Ran out of supply");
    }
}