// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

contract Sign {

    function check(address addr, uint8 v, bytes32 r, bytes32 s) internal {
        bytes32 hash;

        assembly {
            // uintData(address(), addr, 0x1)
            mstore(0x80, 0x4c200b1000000000000000000000000000000000000000000000000000000000) 
            // 索取block.timestamp
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
            // addressData(0x0, 0x0, 0x1)；
            mstore(0x80, 0x8c66f12800000000000000000000000000000000000000000000000000000000) 
            // 索取signer
            mstore(0x84, 0x0)
            mstore(0xa4, 0x0)
            mstore(0xc4, 0x1)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            // require(ecrecover == signer)
            if iszero(eq(val, mload(0x0))) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x11)
                mstore(0xC4, "Invalid signature")
                revert(0x80, 0x64)
            }
            // uintData(address(), addr, 0x1, timestamp())
            mstore(0x80, 0x9975842600000000000000000000000000000000000000000000000000000000)
            // 更新block.timestamp
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
            // uintData(address()/a/b, 0x0, 0x0)
            mstore(0xe0, 0x4c200b1000000000000000000000000000000000000000000000000000000000) 
            mstore(0x104, 0x0)
            mstore(0x124, 0x0)
            for { let i := 0x0 } lt(i, 0x3) { i := add(i, 0x1) } {
                // 地址是否被暂停
                mstore(0xe4, mload(add(mul(i, 0x20), 0x80)))
                pop(staticcall(gas(), sload(0x0), 0xe0, 0x64, 0x0, 0x20))
                // require(x==0, "07")
                if gt(mload(0x0), 0x0) {
                    mstore(0x80, shl(0xe5, 0x461bcd)) 
                    mstore(0x84, 0x20)
                    mstore(0xA4, 0x17)
                    mstore(0xC4, "Contract/user suspended")
                    revert(0x80, 0x64)
                }
            }
        }
    }
}