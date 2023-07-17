//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {DID} from "Contracts/DID.sol";

contract Sign {

    DID internal iDID;

    constructor(address did) {
        iDID = DID(did);
    }

    function check(address addr, uint8 v, bytes32 r, bytes32 s) internal {
        //index: 1688453994
        //r: 0x5515b4dad34a913c278838a1418b51506144fc7e3919fb58b5a03b31deca4c72
        //s: 0x4f8ca63bd9168cc8cff1bca91bf3a85a962fccb427602d8c8e453a0afe0d2974
        // v: 28
        
        //签名条件
        uint counter = iDID.uintData(address(this), addr, address(1));
        bytes32 hash;

        assembly {
            mstore(0x0, add(addr, counter))
            mstore(0x0, keccak256(0x0, 0x20))
            hash := keccak256(0x0, 0x20)
        }

        //require(ecrecover(hash, v, r, s) == iDID.addressData(address(0), 0, 1), "03");
        bool con = ecrecover(hash, v, r, s) == iDID.addressData(address(0), 0, 1);
        
        assembly {
            if iszero(con) {
                mstore(0, shl(0xe0, 0x5b4fb734))
                mstore(4, 0x3)
                revert(0, 0x24)
            }
        }
        
        //更新计数以，用最后的时间戳
        iDID.uintData(address(this), addr, address(1), block.timestamp);

    }
    
}