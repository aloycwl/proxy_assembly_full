// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {UUPSUpgradeable} from "./UUPS.sol";
import {ERC721} from "../ERC721.sol";

contract ERC721P is ERC721, UUPSUpgradeable {


    constructor() ERC721(address(0), "", "") { }

    function initialize(address sto, string memory nam, string memory sym) external {
        init();
        assembly {
            sstore(STO, sto)
            sstore(NAM, mload(nam))
            sstore(NA2, mload(add(nam, 0x20)))
            sstore(SYM, mload(sym))
            sstore(SY2, mload(add(sym, 0x20)))
            // owner = msg.sender 不能用DynamicPrice constructor因为写不进
            sstore(0x658a3ae51bffe958a5b16701df6cfe4c3e73eac576c08ff07c35cf359a8a002e, caller())
        }
    }
    
}