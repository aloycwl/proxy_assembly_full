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
        
        //签名条件
        uint counter = iDID.uintData(address(this), addr, address(1));
        bytes32 hash;

        assembly {
            mstore(0x0, add(addr, counter))
            mstore(0x0, keccak256(0x0, 0x20))
            hash := keccak256(0x0, 0x20)
        }

        require(ecrecover(hash, v, r, s) == iDID.addressData(address(0), 0, 0), "03");
                /*keccak256(abi.encodePacked(keccak256(abi.encodePacked(
                    string.concat(
                        toString(uint(uint160(addr))), 
                        toString(iDID.uintData(address(this), addr, address(1))))
                    )
                )))*/

        //更新计数以，用最后的时间戳
        iDID.uintData(address(this), addr, address(1), block.timestamp);

    }

    /*function toString(uint a) private pure returns (string memory val) {

        assembly {
            let l

            val := mload(0x40)
            mstore(0x40, 0x20)
            mstore(0x80, 0x20)

            if iszero(a) {
                mstore(0xa0, 0x30)
            }

            for { let j := a } gt(j, 0x0) { j := div(j, 0xa) } {
                l := add(l, 0x1)
            }

            for { } gt(a, 0x0) { a := div(a, 0xa) } {
                l := sub(l, 0x1)
                mstore8(add(l, 0xa0), add(mod(a, 0xa), 0x30))
            }
        }
        
    }*/
    
}