// SPDX-License-Identifier: None
pragma solidity 0.8.23;
pragma abicoder v2;

import {Top5} from "../Governance/Top5.sol";
import {Check} from "../Util/Check.sol";
import {DynamicPrice} from "../Util/DynamicPrice.sol";

contract Attachment is Check, DynamicPrice, Top5 {

    function _mint(string memory uri) private {
        assembly {
            let tid := add(sload(INF), 0x01) // count++
            sstore(INF, tid)

            mstore(0x00, caller()) // balanceOf(msg.sender)++
            let tmp := keccak256(0x00, 0x20)
            sstore(tmp, add(sload(tmp), 0x01))
            
            mstore(0x00, tid) // ownerOf[tid] = msg.sender
            tmp := keccak256(0x00, 0x20)
            sstore(tmp, caller()) 

            sstore(add(tmp, 0x01), mload(add(uri, 0x20))) // tokenURI[tid] = uri
            sstore(add(tmp, 0x02), mload(add(uri, 0x40)))
            
            log4(0x00, 0x00, ETF, 0x00, caller(), tid) // emit Transfer()
        }
    }

    function mint(uint lis, string[] calldata uris, uint8 v, bytes32 r, bytes32 s) external payable {
        uint len = uris.length;
        bytes32 tmp;
        unchecked {
            for(uint i; i < len; ++i) _mint(uris[i]);
        }
        assembly {
            tmp := add(AFA, lis)
        }
        _pay(tmp, owner(), len);
        isVRS(lis, v, r, s);
        setTop5(msg.sender);
    }

    function burn(uint tid) public {
        assembly {
            mstore(0x00, tid) // ownerOf(tid)
            let ptr := keccak256(0x00, 0x20)
            let frm := sload(ptr)

            if iszero(eq(frm, caller())) { // require(ownerOf(tid) == msg.sender)
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER2)
                revert(0x80, 0x64)
            }
            
            sstore(ptr, 0x00) // ownerOf[id] = toa
            sstore(add(ptr, 0x03), 0x00) // approve[tid] = toa

            mstore(0x00, frm) // balanceOf(msg.sender)--
            let tmp := keccak256(0x00, 0x20)
            sstore(tmp, sub(sload(tmp), 0x01))

            log4(0x00, 0x00, ETF, frm, 0x00, tid) // emit Transfer()
        }
    }

    // 烧毁再mint
    function merge(uint[] calldata ids, uint lis, string calldata uri, uint8 v, bytes32 r, bytes32 s) external payable {
        unchecked {
            for(uint i; i < ids.length; ++i) burn(ids[i]);
        }
        _mint(uri);
        isVRS(lis, v, r, s);
    }

    // 升级
    function upgrade(uint lis, uint tid, string memory uri, uint8 v, bytes32 r, bytes32 s) external payable {
        bytes32 tmp;

        assembly {
            mstore(0x00, tid) // ownerOf(tid)
            tmp := keccak256(0x00, 0x20)
            mstore(0x00, sload(tmp)) 
            
            if iszero(eq(mload(0x00), caller())) { // require(ownerOf(tid) == msg.sender)
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER2)
                revert(0x80, 0x64)
            }
            
            sstore(add(tmp, 0x01), mload(add(uri, 0x20))) // tokenURI[tid] = uri
            sstore(add(tmp, 0x02), mload(add(uri, 0x40)))

            tmp := add(AFA, lis)
        }

        _pay(tmp, owner(), 1);
        isVRS(lis, v, r, s);
    }

}