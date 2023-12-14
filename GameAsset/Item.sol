// SPDX-License-Identifier: None
pragma solidity 0.8.23;
pragma abicoder v2;

import {Attachment} from "../GameAsset/Attachment.sol";

contract Item is Attachment {

    event Transfer(address indexed, address indexed, uint indexed);
    event Approval(address indexed, address indexed, uint indexed);
    event ApprovalForAll(address indexed, address indexed, bool);

    function supportsInterface(bytes4 a) external pure returns(bool) {
        assembly {
            mstore(0x00, or(eq(a, INF), eq(a, IN2)))
            return(0x00, 0x20)
        }
    }

    function name() external pure returns(string memory) {
        assembly {
            mstore(0x80, 0x20)
            mstore(0xa0, 0x08)
            mstore(0xc0, "Game NFT")
            return(0x80, 0x60)
        }
    }

    function symbol() external pure returns(string memory) {
        assembly {
            mstore(0x80, 0x20)
            mstore(0xa0, 0x02)
            mstore(0xc0, "GN")
            return(0x80, 0x60)
        }
    }

    function count() external view returns(uint) {
        assembly {
            mstore(0x00, sload(INF))
            return(0x00, 0x20)
        }
    }

    function balanceOf(address adr) external view returns (uint) {
        assembly {
            mstore(0x00, adr)
            mstore(0x00, sload(keccak256(0x00, 0x20)))
            return(0x00, 0x20)
        }
    }

    function ownerOf(uint tid) external view returns(address) {
        assembly {
            mstore(0x00, tid)
            mstore(0x00, sload(keccak256(0x00, 0x20))) // 用0x00为储存
            return(0x00, 0x20)
        }
    }
    
    function tokenURI(uint tid) external view returns (string memory) {
        assembly {
            mstore(0x00, tid)
            let tmp := keccak256(0x00, 0x20)
            mstore(0x80, 0x20)
            mstore(0xa0, 0x35)
            mstore(0xc0, sload(add(tmp, 0x01))) // 用0x01和0x02为储存
            mstore(0xe0, sload(add(tmp, 0x02)))
            return(0x80, 0x80)
        }
    }

    function getApproved(uint tid) external view returns(address) {
        assembly {
            mstore(0x00, tid)
            mstore(0x00, sload(add(keccak256(0x00, 0x20), 0x03))) // 用0x03为储存
            return(0x00, 0x20)
        }
    }

    function isApprovedForAll(address frm, address toa) external view returns(bool) {
        assembly {
            mstore(0x00, frm)
            mstore(0x20, toa)
            mstore(0x00, sload(keccak256(0x00, 0x40)))
            return(0x00, 0x20)
        }
    }

    function approve(address toa, uint tid) external {
        assembly {
            mstore(0x00, tid) // ownerOf(tid)
            let tmp := keccak256(0x00, 0x20)
            let oid := sload(tmp) 

            mstore(0x00, oid) // isApprovedForAll(oid, msg.sender)
            mstore(0x20, caller())
            mstore(0x00, sload(keccak256(0x00, 0x40)))

            // require(msg.sender == ownerOf(tid) || isApprovedForAll(ownerOf(tid), msg.sender))
            if and(iszero(eq(caller(), oid)), iszero(mload(0x00))) {
                mstore(0x80, ERR)
                mstore(0xa0, STR)
                mstore(0xc0, ER1)
                revert(0x80, 0x64)
            }
            
            sstore(add(tmp, 0x03), toa) // approve[tid] = toa

            log4(0x00, 0x00, EAP, oid, toa, tid) // emit Approval()
        }
    }

    function setApprovalForAll(address toa, bool bol) external {
        assembly {
            mstore(0x00, caller())
            mstore(0x20, toa)
            sstore(keccak256(0x00, 0x40), bol)
            
            mstore(0x00, bol) // emit ApprovalForAll()
            log3(0x00, 0x20, EAA, caller(), toa)
        }
    }

    function _transfer(address toa, uint tid) private {
        address frm;

        assembly {
            mstore(0x00, tid) // ownerOf(tid)
            let ptr := keccak256(0x00, 0x20)
            frm := sload(ptr)

            mstore(0x00, frm)
            mstore(0x20, caller())
            let tmp:= sload(keccak256(0x00, 0x40))

            mstore(0x00, sload(add(ptr, 0x03))) // getApproved(id)

            // require(getApproved(tid) == toa || ownerOf(tid) == msg.sender || isApprovedForAll(msg.sender))
            if and(and(iszero(eq(mload(0x00), toa)), iszero(eq(frm, caller()))), eq(tmp, 0x00)) {
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER2)
                revert(0x80, 0x64)
            }
            
            sstore(ptr, toa) // ownerOf[id] = toa
            sstore(add(ptr, 0x03), 0x00) // approve[tid] = toa

            mstore(0x00, frm) // balanceOf(msg.sender)--
            tmp := keccak256(0x00, 0x20)
            sstore(tmp, sub(sload(tmp), 0x01))

            mstore(0x00, toa) // balanceOf(toa)++
            tmp := keccak256(0x00, 0x20)
            sstore(tmp, add(sload(tmp), 0x01))

            log4(0x00, 0x00, ETF, frm, toa, tid) // emit Transfer()
        }
        isSuspended(frm, toa);
        setTop5(toa);
    }

    function transferFrom(address, address toa, uint tid) external {
        _transfer(toa, tid);
    }

    function safeTransferFrom(address, address toa, uint tid) external {
        _transfer(toa, tid);
    }

    function safeTransferFrom(address, address toa, uint tid, bytes memory) external {
        _transfer(toa, tid);
    }
}