// SPDX-License-Identifier: None
pragma solidity 0.8.18;
pragma abicoder v1;

import {Access} from "../Util/Access.sol";

contract Storage is Access {
    
    constructor() {
        assembly {
            sstore(0xcbfe4baa920060fc34aa65135b74b83fa81df36f6e21d90c8301c8810d2c89d9, caller()) // signer
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
    function uintData(bytes32 a) external view returns(uint) { // 0x84d6ad61 | piloting
        assembly{
            mstore(0x00, sload(a))
            return(0x00, 0x20)
        }
    }
    function uintData(bytes32 a, uint b) external onlyAccess { //0x7fef772c | piloting
        assembly {
            sstore(a, b)
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
    function addressData(bytes32 a) external view returns(address) { // 0x385b2e60 | piloting
        assembly{
            mstore(0x00, sload(a))
            return(0x00, 0x20)
        }
    }
    function addressData(bytes32 a, address b) external onlyAccess { //0x6202a118 | piloting
        assembly {
            sstore(a, b)
        }
    }

    /*
    CIDData[a][b] = c
    */
    function CIDData(address a, uint b) external view returns(string memory) { // 0x99eec064
        assembly{
            mstore(0x00, a)
            mstore(0x20, b)
            let d := keccak256(0x0, 0x40)
            mstore(0x80, 0x20)
            mstore(0xa0, 0x2e)
            mstore(0xc0, sload(add(d, 0x01)))
            mstore(0xe0, sload(add(d, 0x02)))
            return(0x80, 0x80)
        }
    }
    function CIDData(address a, uint b, bytes32 c, bytes32 d) external onlyAccess { // 0x4155d39b
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            let f := keccak256(0x00, 0x40)
            sstore(f, 0x2e)
            sstore(add(f, 0x01), c)
            sstore(add(f, 0x02), d)
        }
    }
    function CIDData(bytes32 a) external view returns(string memory) { // 0xbf52de05 | piloting
        assembly{
            mstore(0x80, 0x20)
            mstore(0xa0, 0x2e)
            mstore(0xc0, sload(add(a, 0x01)))
            mstore(0xe0, sload(add(a, 0x02)))
            return(0x80, 0x80)
        }
    }
    function CIDData(bytes32 a, bytes32 b, bytes32 c) external onlyAccess { //0x08d81100 | piloting
        assembly {
            sstore(a, 0x2e)
            sstore(add(a, 0x01), b)
            sstore(add(a, 0x02), c)
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
            mstore(0x20, sload(add(f, 0x01)))
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
            sstore(add(f, 0x01), e)
        }
    }
    function listData(bytes32 a) external view returns(address, uint) { // 0xaf70c300 | piloting
        assembly{
            mstore(0x00, sload(a))
            mstore(0x20, sload(add(a, 0x01)))
            return(0x00, 0x40)
        }
    }
    function listData(bytes32 a, address b, uint c) external onlyAccess { //0x70434fbd | piloting
        assembly {
            sstore(a, b)
            sstore(add(a, 0x01), c)
        }
    }

    /*
    uintEnum[a][b].push(a, b) & pop(a, b)
    */
    function uintEnum(bytes32 a) external view returns(uint[] memory) { // 0x650baf60
        assembly { 
            let len := sload(a) // 设长度
            mstore(0x80, 0x20)
            mstore(0xa0, len)
            for { let i := 0x00 } lt(i, add(len, 0x01)) { i := add(i, 0x01) } {
                mstore(add(0xa0, mul(i, 0x20)), sload(add(a, i)))
            }
            return(0x80, mul(add(len, 0x02), 0x20))
        }
    }
    function uintPop(bytes32 a, uint b) external onlyAccess { // 0x40061633
        assembly {
            let len := sload(a)
            sstore(a, sub(len, 0x01))
            for { let i := 0x01 } lt(i, add(len, 0x01)) { i := add(i, 0x01) } {
                if eq(b, sload(add(a, i))) {
                    sstore(add(a, i), sload(add(a, len))) // 和最后一个值替换
                    break
                }
            }
        }
    }
    function uintPush(bytes32 a, uint b) external onlyAccess { // 0x7cc553f4
        assembly {
            let len := add(sload(a), 0x01)
            sstore(a, len)
            sstore(add(a, len), b)
        }
    }

}