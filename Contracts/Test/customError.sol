//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

contract TESTSign {

    function check() pure external  {
        uint counter = 0;
        address addr = 0xA34357486224151dDfDB291E13194995c22Df505;
        bytes32 r = 0x3db15f68e04c4a717c853d8392dbb32111d03a0537dcb5d599f8a058baed3b0f;
        bytes32 s = 0x75ded7489e83f2e9140ebcb2b388d6308a39eea6455d51a66cf83d5bea2e377d;
        uint8 v = 28;
        
        //签名条件
        //uint counter = iDID.uintData(address(this), addr, address(1));
        bytes32 hash;

        assembly {
            mstore(0x0, add(addr, counter))
            mstore(0x0, keccak256(0x0, 0x20))
            hash := keccak256(0x0, 0x20)
        }

        //require(ecrecover(hash, v, r, s) == iDID.addressData(address(0), 0, 1), "03");
        address val = ecrecover(hash, v, r, s);
        
        assembly {
            if iszero(eq(val, addr)) {
                mstore(0x0, shl(0xe0, 0x5b4fb734))
                mstore(0x4, 0x3)
                revert(0x0, 0x24)
            }
        }
        
        //更新计数以，用最后的时间戳
        //iDID.uintData(address(this), addr, address(1), block.timestamp);

    }
    
}