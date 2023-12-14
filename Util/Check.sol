// SPDX-License-Identifier: None
pragma solidity 0.8.23;
pragma abicoder v1;

import {Hashes} from "../Util/Hashes.sol";

contract Check is Hashes {

    function isSuspended(address adr) internal view {
        assembly {
            // require(!suspended[address(this)] && !suspended[adr]);
            if or(gt(sload(address()), 0x00), gt(sload(adr), 0x00)) {
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER3)
                revert(0x80, 0x64)
            }
        }
    }

    function isSuspended(address adr, address ad2) internal view {
        assembly {
            // require(!suspended[address(this)] && !suspended[adr] && !suspended[ad2]);
            if or(or(gt(sload(address()), 0x00), gt(sload(adr), 0x00)), gt(sload(ad2), 0x00)) {
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER3)
                revert(0x80, 0x64)
            }
        }
    }

    function isVRS(uint amt, uint8 v, bytes32 r, bytes32 s) internal {
        bytes32 hsh;

        assembly {
            mstore(0x00, origin()) // ind = index[adr]
            let ptr := add(keccak256(0x00, 0x20), 0x01)
            let ind := sload(ptr) 
            
            sstore(ptr, add(ind, 0x01)) // index[adr]++

            mstore(0x80, origin())
            mstore(0xa0, ind)
            mstore(0xc0, amt)
            hsh := keccak256(0x80, 0x60)
        }

        address val = ecrecover(hsh, v, r, s);
        isSuspended(msg.sender);

        assembly {
            if iszero(eq(val, sload(APP))) { // require(val == signer)
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER4)
                revert(0x80, 0x64)
            }
        }
    }

}