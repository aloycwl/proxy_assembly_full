// SPDX-License-Identifier: None
pragma solidity 0.8.18;
pragma abicoder v1;

import {UUPSUpgradeable} from "../Proxy/UUPS.sol";
import {Coin} from "./Coin.sol";

contract CoinP is Coin, UUPSUpgradeable {

    constructor() Coin(address(0), "", "") { }

    function initialize(address sto) external {
        init();
        assembly {
            // 设置string和string.length
            sstore(STO, sto)
            sstore(NAM, 0x0a)
            sstore(NA2, "Coin Proxy")
            sstore(SYM, 0x03)
            sstore(SY2, "CoP")
        } 
    }

}