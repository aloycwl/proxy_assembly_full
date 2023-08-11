// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {UUPSUpgradeable} from "./UUPS.sol";
import {Market} from "../Market.sol";

contract MarketP is Market, UUPSUpgradeable {

    bytes32 constant private STO = 0x79030946dd457157e4aa08fcb4907c422402e75f0f0ecb4f2089cb35021ff964;
    bytes32 constant private OWN = 0x658a3ae51bffe958a5b16701df6cfe4c3e73eac576c08ff07c35cf359a8a002e;

    constructor() Market(address(0)) { }

    function initialize(address sto) external {
        init();
        assembly {
            sstore(STO, sto)
            // owner = msg.sender 不能用DynamicPrice constructor因为写不进
            sstore(OWN, caller())
            // 设置access, 不能用Access constructor因为写不进
            sstore(caller(), 0xff)
        }
    }
    
}