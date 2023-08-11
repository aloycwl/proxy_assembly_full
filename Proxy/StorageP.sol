// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {UUPSUpgradeable} from "./UUPS.sol";
import {Storage} from "../Storage.sol";

contract StorageP is Storage, UUPSUpgradeable {

    function initialize() external {
        init();
        assembly {
            // 设置signer
            mstore(0x80, 0x00)
            mstore(0xa0, 0x00)
            mstore(0xc0, 0x01)
            sstore(keccak256(0x80, 0x60), caller())
            // 设置access, 不能用Access constructor因为写不进
            sstore(caller(), 0xff)
        }
    }

}