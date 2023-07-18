//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

contract Sign {

    constructor(address did) {
        assembly {
            sstore(0x0, did)
        }
    }

    function check(address addr, uint8 v, bytes32 r, bytes32 s) internal {
        bytes32 hash;

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0x4c200b10)) // uintData(address,addrress,address)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x24), addr)
            mstore(add(ptr, 0x44), 0x1)
            pop(staticcall(gas(), sload(0x0), ptr, 0x64, 0x0, 0x20))
            // 拿哈希信息
            mstore(0x0, add(addr, mload(0x0)))
            mstore(0x0, keccak256(0x0, 0x20))
            hash := keccak256(0x0, 0x20)
        }

        address val = ecrecover(hash, v, r, s);
        
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0x8c66f128)) // addressData(address,uint256,uint256)；
            mstore(add(ptr, 0x04), 0x0)
            mstore(add(ptr, 0x24), 0x0)
            mstore(add(ptr, 0x44), 0x1)
            pop(staticcall(gas(), sload(0x0), ptr, 0x64, 0x0, 0x20))
            // 跟签名地址对比
            if iszero(eq(val, mload(0x0))) {
                mstore(0x0, shl(0xe0, 0x5b4fb734))
                mstore(0x4, 0x3)
                revert(0x0, 0x24)
            }
            //用时间戳更新计数
            mstore(ptr, shl(0xe0, 0x99758426)) // uintData(address,address,address,uint256)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x24), addr)
            mstore(add(ptr, 0x44), 0x1)
            mstore(add(ptr, 0x64), timestamp())
            pop(call(gas(), sload(0x0), 0x0, ptr, 0x84, 0x0, 0x0))
        }
    }   
}