// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {Storage} from "../Storage.sol";
import {ERC721} from "../ERC721.sol";
import {ERC20} from "../ERC20.sol";
import {Market} from "../Market.sol";

contract Deployer {

    address public STO;
    address public ER2;
    address public ER7;
    address public MKT;

    constructor() {
        (STO, ER2, ER7, MKT) = (address(new Storage()),
            address(new ERC20(STO, "Wild Dynasty Token", "WDT")),
            address(new ERC721(STO, "Wild Dynasty", "WD")),
            address(new Market(STO)));

        assembly {
            let sto := sload(STO.slot)
            // setAccess()
            mstore(0x80, 0x850bbe8700000000000000000000000000000000000000000000000000000000)
            mstore(0x84, caller())
            mstore(0xa4, 0x01)
            pop(call(gas(), sto, 0x00, 0x80, 0x44, 0xa0, 0x80))
            mstore(0x84, sload(ER2.slot))
            mstore(0xa4, 0x01)
            pop(call(gas(), sto, 0x00, 0x80, 0x44, 0xa0, 0x80))
            mstore(0x84, sload(ER7.slot))
            mstore(0xa4, 0x01)
            pop(call(gas(), sto, 0x00, 0x80, 0x44, 0xa0, 0x80))
            mstore(0x84, sload(MKT.slot))
            mstore(0xa4, 0x01)
            pop(call(gas(), sto, 0x00, 0x80, 0x44, 0xa0, 0x80))
        }
    }

}