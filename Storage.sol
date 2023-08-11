// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {Access} from "../Util/Access.sol";

contract Storage is Access {
    
    constructor() {
        assembly {
            //设置signer
            mstore(0x80, 0x00)
            mstore(0xa0, 0x00)
            mstore(0xc0, 0x01)
            sstore(keccak256(0x80, 0x60), caller())
        }
    }
    /*
    did[a] = b
    */
    function did(string memory a) external view returns(address) { // 0x31b35552
        assembly {
            mstore(0x00, sload(keccak256(a, 0x40)))
            return(0x00, 0x20)
        }
    }
    function did(string memory a, address b) external onlyAccess { // 0x7148bc72
        assembly {
            sstore(keccak256(a, 0x40), b)
        }
    }
    /*
    uintData[a][b][c] = d
    */
    function uintData(address a, address b, address c) external view returns(uint) { // 0x4c200b10
        assembly{
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            mstore(0x00, sload(keccak256(0x80, 0x60)))
            return(0x00, 0x20)
        }
    }
    function uintData(address a, address b, address c, uint d) external onlyAccess { // 0x99758426
        assembly {
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            sstore(keccak256(0x80, 0x60), d)
        }
    }
    /*
    addressData[a][b][c] = d
    */
    function addressData(address a, uint b, uint c) external view returns(address) { // 0x8c66f128
        assembly{
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            mstore(0x00, sload(keccak256(0x80, 0x60)))
            return(0x00, 0x20)
        }
    }
    function addressData(address a, uint b, uint c, address d) external onlyAccess { // 0x8c66f128
        assembly{
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            sstore(keccak256(0x80, 0x60), d)
        }
    }
    /*
    stringData[a][b] = c
    */
    function stringData(address a, uint b) external view returns(string memory) { // 0x99eec064
        assembly{
            mstore(0x00, a)
            mstore(0x20, b)
            let d := keccak256(0x0, 0x40)
            mstore(0x80, 0x20)
            mstore(0xa0, 0x25)
            mstore(0xc0, sload(add(d, 0x20)))
            mstore(0xe0, sload(add(d, 0x40)))
            return(0x80, 0x80)
        }
    }
    function stringData(address a, uint b, uint c, bytes32 d, bytes32 e) external onlyAccess { // 0x4155d39b
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            let f := keccak256(0x00, 0x40)
            sstore(f, c)
            sstore(add(f, 0x20), d)
            sstore(add(f, 0x40), e)
        }
    }
    /*
    lists[a][b][c] = List(d, e);
    */
    function listData(address a, address b, uint c) external view returns(address, uint) { // 0xdf0188db
        assembly{
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            let f := keccak256(0x80, 0x60)
            mstore(0x00, sload(f))
            mstore(0x20, sload(add(f, 0x20)))
            return(0x00, 0x40)
        }
    }
    function listData(address a, address b, uint c, address d, uint e) external onlyAccess { // 0x41aa4436
        assembly {
            mstore(0x00, a)
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
            mstore(0x00, a)
            mstore(0x20, b)
            let ptr := keccak256(0x00, 0x40)
            mstore(0x00, ptr)
            len := sload(ptr)
        }

        val = new uint[](len);

        assembly {
            let ptr := keccak256(0x00, 0x20)
            for { let i := 0x00 } lt(i, len) { i := add(i, 0x01) } {
                mstore(add(val, mul(add(i, 0x01), 0x20)), sload(add(ptr, i)))
            }
        }
    }
    function uintEnum(address a, address b, uint c, uint d) external onlyAccess { // 0x6795d526
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            let ptr := keccak256(0x00, 0x40)
            let len := sload(ptr)

            switch d 
                case 1 { // pop()
                    sstore(ptr, sub(len, 0x1)) 
                    mstore(0x00, ptr)
                    ptr := keccak256(0x00, 0x20)
                    d := sload(add(ptr, sub(len, 0x01)))
                    for { let i := 0x00 } lt(i, len) { i := add(i, 0x01) } {
                        if eq(c, sload(add(ptr, i))) {
                            len := i
                        }
                    }
                }
                default { // push()
                    sstore(ptr, add(len, 0x01))
                    d := c
                    mstore(0x00, ptr)
                    ptr := keccak256(0x00, 0x20)
                }
            sstore(add(ptr, len), d)
        }
    }
}