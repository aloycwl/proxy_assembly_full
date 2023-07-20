//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

contract TestEnum {

    //获取地址拥有的所有代币的数组
    /*function tokensOwned() external view returns(uint[] memory val) {

        uint len;
        address contAddr = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        address did = 0x6E111eaf89bbfC1210F413f63f0A35D34a75243f;
        address addr = msg.sender;

        // 先拿数组长度
        assembly {
            mstore(0x80, shl(0xe0, 0x82ff9d6f)) // uintEnum(address,address)
            mstore(0x84, contAddr)
            mstore(0xa4, addr)
            pop(staticcall(gas(), did, 0x80, 0x84, 0x0, 0x40))
            len := mload(0x20)
        }

        val = new uint[](len);

        // 再每格插入
        assembly {
            //let ptr := mload(0x40)
            mstore(0x80, shl(0xe0, 0x82ff9d6f)) // uintEnum(address,address)
            mstore(0x84, contAddr)
            mstore(0xa4, addr)
            pop(staticcall(gas(), did, 0x80, 0x84, 0xa0, mul(add(len, 0x2), 0x20)))
            
            for { let i := 0x0 } lt(i, add(len, 0x2)) { i := add(i, 0x1) } {
                mstore(add(val, mul(i, 0x20)), mload(add(0xa0, mul(add(i, 0x1), 0x20))))
            }
        }
    }*/

    function transferFrom(address from, address to, bool isa) external pure {

        address oid = 0x5171e2d76B3D114e06712320D5c1534cB0107455;
        address app = 0xD2457926Dc6A49AfbD479E840ae44F86a921C5f1;
        
            /*require(oid == from ||                                            //所有者
                    app == to ||                                        //被授权
                    iaa, "0C");                           //执行者*/
     
        assembly {
            if and(and(iszero(eq(app, to)), iszero(eq(oid, from))), iszero(isa)) {
                mstore(0x0, shl(0xe0, 0x5b4fb734))
                mstore(0x4, 0xc)
                revert(0x0, 0x24)
            }
        }
    }
}