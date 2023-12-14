// SPDX-License-Identifier: None
pragma solidity 0.8.23;
pragma abicoder v1;

import {Hashes} from "../Util/Hashes.sol";

contract Top5 is Hashes {

    function isTop5(address adr) external view returns(bool) {
        assembly {
            for { let i } lt(i, 0x05) { i := add(i, 0x01) } {
                if eq(adr, sload(add(TP5, i))) { mstore(0x00, 0x01) }
            }
            return(0x00, 0x20)
        }
    }

    function getTop5() external view returns(address[5] memory) {
        assembly {
            mstore(0x80, sload(TP5))
            mstore(0xa0, sload(add(TP5, 0x01)))
            mstore(0xc0, sload(add(TP5, 0x02)))
            mstore(0xe0, sload(add(TP5, 0x03)))
            mstore(0x0100, sload(add(TP5, 0x04)))
            return(0x80, 0xa0)
        }
    }

    function setTop5(address top) internal {
        assembly {
            let ind
            let lwt := ETF

            for { let i } lt(i, 0x05) { i := add(i, 0x01) } {
                let adr := sload(add(TP5, i))
                if eq(adr, top) { return(0x00, 0x00) }
                mstore(0x00, adr)
                let tmp := sload(keccak256(0x00, 0x20))
                if lt(tmp, lwt) {
                    ind := i
                    lwt := tmp
                }
            }

            mstore(0x00, top)
            if gt(sload(keccak256(0x00, 0x20)), lwt) {
                sstore(add(TP5, ind), top)
            }
        }
    }
}