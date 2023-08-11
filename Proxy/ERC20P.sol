// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {UUPSUpgradeable} from "./UUPS.sol";
import {ERC20} from "../ERC20.sol";

// gas: 974705
contract ERC20P is ERC20, UUPSUpgradeable {

    bytes32 constant private STO = 0x79030946dd457157e4aa08fcb4907c422402e75f0f0ecb4f2089cb35021ff964;
    bytes32 constant private NAM = 0xbfc6089389a8677a26de8a30917b1b15a173691b166f48a89b49eec213ba87b0;
    bytes32 constant private NA2 = 0xf2611493f75085dca50c1fd2ac8e34bc6d0eb7c274307efa54c50582314985bf;
    bytes32 constant private SYM = 0x4d3015a52e62e7dc6887dd6869969b57532cf58982b1264ed2b19809b668f8e5;
    bytes32 constant private SY2 = 0x96d8c7e9753d0c3dce20e0bd54a10932c96cf8457fe2ac7cebc4ca70af17a39a;

    constructor() ERC20(address(0), "", "") { }

    function initialize(address sto, string memory nam, string memory syb) external {
        init();
        assembly {
            // 设置string和string.length
            sstore(STO, sto)
            sstore(NAM, mload(nam))
            sstore(NA2, mload(add(nam, 0x20)))
            sstore(SYM, mload(syb))
            sstore(SY2, mload(add(syb, 0x20)))
        } 
    }

}