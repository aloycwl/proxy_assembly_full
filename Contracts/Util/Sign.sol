// SPDX-License-Identifier: None
// solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

contract Sign {

    function check(address addr, uint8 v, bytes32 r, bytes32 s) internal {
        bytes32 hash;

        assembly {
            // 索取block.timestamp
            mstore(0x80, shl(0xe0, 0x4c200b10)) // uintData(address,addrress,address)
            mstore(0x84, address())
            mstore(0xa4, addr)
            mstore(0xc4, 0x1)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            // 拿哈希信息
            mstore(0x0, add(addr, mload(0x0)))
            mstore(0x0, keccak256(0x0, 0x20))
            hash := keccak256(0x0, 0x20)
        }

        address val = ecrecover(hash, v, r, s);
        
        assembly {
            // 索取signer
            mstore(0x80, shl(0xe0, 0x8c66f128)) // addressData(address,uint256,uint256)；
            mstore(0x84, 0x0)
            mstore(0xa4, 0x0)
            mstore(0xc4, 0x1)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            // 跟签名地址对比
            if iszero(eq(val, mload(0x0))) {
                mstore(0x0, shl(0xe0, 0x5b4fb734))
                mstore(0x4, 0x3)
                revert(0x0, 0x24)
            }
            //更新block.timestamp
            mstore(0x80, shl(0xe0, 0x99758426)) // uintData(address,address,address,uint256)
            mstore(0x84, address())
            mstore(0xa4, addr)
            mstore(0xc4, 0x1)
            mstore(0xe4, timestamp())
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))
        }
    }

    function checkSuspend(address a, address b) internal view {
        assembly {
            // 环这3个地址
            mstore(0x80, address())
            mstore(0xa0, a)
            mstore(0xc0, b)
            // 不用改的变量放外面
            mstore(0xe0, shl(0xe0, 0x4c200b10)) // uintData(address,address,address)
            mstore(0x104, 0x0)
            mstore(0x124, 0x0)
            for { let i := 0x0 } lt(i, 0x3) { i := add(i, 0x1) } {
                // 地址是否被暂停
                mstore(0xe4, mload(add(mul(i, 0x20), 0x80)))
                pop(staticcall(gas(), sload(0x0), 0xe0, 0x64, 0x0, 0x20))
                // require(x==0, "07")
                if gt(mload(0x0), 0x0) {
                    mstore(0x0, shl(0xe0, 0x5b4fb734))
                    mstore(0x4, 0x7)
                    revert(0x0, 0x24)
                }
            }
        }
    }
}