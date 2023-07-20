//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Access} from "Contracts/Util/Access.sol";

struct List {
    address tokenAddr;
    uint price;
}

contract DID is Access {
    
    constructor() {
        assembly { //设置签名人
            mstore(0x0, 0x0)
            mstore(0x20, 0x0)
            mstore(0x40, 0x1)
            sstore(keccak256(0x0, 0x60), caller())
        }
    }
    /*
    did[a] = b
    */
    function did(string memory a) external view returns(address val) { // 0x31b35552
        assembly {
            val := sload(keccak256(a, 0x40))
        }
    }
    function did(string memory a, address b) external OnlyAccess { // 0x7148bc72
        assembly {
            sstore(keccak256(a, 0x40), b)
        }
    }
    /*
    uintData[a][b][c] = d
    */
    function uintData(address a, address b, address c) external view returns(uint val) { // 0x4c200b10
        assembly{
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            val := sload(keccak256(0x80, 0x60))
        }
    }
    function uintData(address a, address b, address c, uint d) external OnlyAccess { // 0x99758426
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            mstore(0x40, c)
            sstore(keccak256(0x0, 0x60), d)
        }
    }
    /*
    addressData[a][b][c] = d
    */
    function addressData(address a, uint b, uint c) external view returns(address val) { // 0x8c66f128
        assembly{
            mstore(0x0, a)
            mstore(0x20, b)
            mstore(0x40, c)
            val := sload(keccak256(0x0, 0x60))
        }
    }
    function addressData(address a, uint b, uint c, address d) external OnlyAccess { // 0xed3dae2b
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            mstore(0x40, c)
            sstore(keccak256(0x0, 0x60), d)
        }
    }
    /*
    stringData[a][b][c] = d
    */
    function stringData(address a, uint b) external view returns(string memory val) { // 0x99eec064
        assembly{
            mstore(0x0, a)
            mstore(0x20, b)
            let d := keccak256(0x0, 0x40)
            val := mload(0x40)
            mstore(0x40, add(val, 0x60))
            mstore(val, sload(d))
            mstore(add(val, 0x20), sload(add(d, 0x20)))
            mstore(add(val, 0x40), sload(add(d, 0x40)))
        }
    }
    /*function stringData(address a, uint b, string memory c) external OnlyAccess { // 0xea502ecf
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            let d := keccak256(0x0, 0x40)
            sstore(d, mload(c))
            sstore(add(d, 0x20), mload(add(c, 0x20)))
            sstore(add(d, 0x40), mload(add(c, 0x40)))
        }
    }*/
    function stringData(bytes32 a, bytes32 b, bytes32 c, bytes32 d, bytes32 e) external OnlyAccess { // 0xc7070b58
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            let f := keccak256(0x0, 0x40)
            sstore(f, c)
            sstore(add(f, 0x20), d)
            sstore(add(f, 0x40), e)
        }
    }
    /*
    lists[a][b][c] = List(d, e);
    */
    function listData(address a, address b, uint c) external view returns(address d, uint e) { // 0xdf0188db
        assembly{
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            let f := keccak256(0x80, 0x60)
            d := sload(f)
            e := sload(add(f, 0x20))
        }
    }
    function listData(address a, address b, uint c, address d, uint e) external OnlyAccess { // 0x41aa4436
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            mstore(0x40, c)
            let f := keccak256(0x0, 0x60)
            sstore(f, d)
            sstore(add(f, 0x20), e)
        }
    }
    /*
    _uintEnum[a][b].push(a, b, c, 0) & pop(a, b, c, 1)
    */
    function uintEnum(address a, address b) external view returns(uint[] memory val) { // 0x82ff9d6f

        uint len;
        
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            let ptr := keccak256(0x0, 0x40)
            mstore(0x0, ptr)
            len := sload(ptr)
        }

        val = new uint[](len);

        assembly {
            let ptr := keccak256(0x0, 0x20)
            for { let i := 0x0 } lt(i, len) { i := add(i, 0x1) } {
                mstore(add(val, mul(add(i, 0x1), 0x20)), sload(add(ptr, i)))
            }
        }
    }
    function uintEnum(address a, address b, uint c, uint d) external OnlyAccess { // 0x6795d526
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            let ptr := keccak256(0x0, 0x40)
            let len := sload(ptr)

            switch d 
                case 1 { // pop()
                    sstore(ptr, sub(len, 0x1)) 
                    mstore(0x0, ptr)
                    ptr := keccak256(0x0, 0x20)
                    d := sload(add(ptr, sub(len, 0x1)))
                    for { let i := 0x0 } lt(i, len) { i := add(i, 0x1) } {
                        if eq(c, sload(add(ptr, i))) {
                            len := i
                        }
                    }
                }
                default { // push()
                    sstore(ptr, add(len, 0x1))
                    d := c
                    mstore(0x0, ptr)
                    ptr := keccak256(0x0, 0x20)
                }
            sstore(add(ptr, len), d)
        }
    }
}