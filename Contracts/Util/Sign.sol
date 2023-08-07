// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

contract Sign {

    bytes32 constant private STO = 0x79030946dd457157e4aa08fcb4907c422402e75f0f0ecb4f2089cb35021ff964;

    function check(address adr, uint8 v, bytes32 r, bytes32 s) internal {

        bytes32 hash;

        assembly {
            // uintData(address(), addr, 0x1)
            mstore(0x80, 0x4c200b1000000000000000000000000000000000000000000000000000000000) 
            // 索取block.timestamp
            mstore(0x84, address())
            mstore(0xa4, adr)
            mstore(0xc4, 0x01)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            // 拿哈希信息
            mstore(0x00, add(adr, mload(0x00)))
            mstore(0x00, keccak256(0x00, 0x20))
            hash := keccak256(0x00, 0x20)
        }

        address val = ecrecover(hash, v, r, s);
        
        assembly {
            // addressData(0x0, 0x0, 0x1)；
            mstore(0x80, 0x8c66f12800000000000000000000000000000000000000000000000000000000) 
            // 索取signer
            mstore(0x84, 0x00)
            mstore(0xa4, 0x00)
            mstore(0xc4, 0x01)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
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
            mstore(0xa4, adr)
            mstore(0xc4, 0x01)
            mstore(0xe4, timestamp())
            pop(call(gas(), sload(STO), 0x00, 0x80, 0x84, 0x00, 0x00))
        }
    }

    function checkSuspend(address adr, address ad2) internal view {
        assembly {
            // 环这3个地址
            mstore(0x80, address())
            mstore(0xa0, adr)
            mstore(0xc0, ad2)
            // uintData(address()/a/b, 0x0, 0x0)
            mstore(0xe0, 0x4c200b1000000000000000000000000000000000000000000000000000000000) 
            mstore(0x0104, 0x00)
            mstore(0x0124, 0x00)
            for { let i := 0x00 } lt(i, 0x03) { i := add(i, 0x01) } {
                // 地址是否被暂停
                mstore(0xe4, mload(add(mul(i, 0x20), 0x80)))
                pop(staticcall(gas(), sload(STO), 0xe0, 0x64, 0x00, 0x20))
                // require(x == 0)
                if gt(mload(0x00), 0x00) {
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