//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Access} from "Contracts/Util/Access.sol";

struct List {
    address tokenAddr;
    uint price;
}

//储存和去中心化身份合约
contract DID is Access {

    //设置签名人
    constructor() {
        assembly {
            mstore(0x0, 0x0)
            mstore(0x20, 0x0)
            mstore(0x40, 0x1)
            sstore(keccak256(0x0, 0x60), caller())
        }
    }

    /*
    *
    *
    did[a] = b
    *
    * 
    */
    function did(string memory a) external view returns(address val) {
        assembly {
            val := sload(keccak256(a, 0x40))
        }
    }

    function did(string memory a, address b) external OnlyAccess {
        assembly {
            sstore(keccak256(a, 0x40), b)
        }
    }

    /*
    *
    *
    uintData[a][b][c] = d
    *
    *
    */
    function uintData(address a, address b, address c) external view returns(uint val) {
        assembly{
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            val := sload(keccak256(0x80, 0x60))
        }
    }

    function uintData(address a, address b, address c, uint d) external OnlyAccess {
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            mstore(0x40, c)
            sstore(keccak256(0x0, 0x60), d)
        }
    }

    /*
    *
    *
    addressData[a][b][c] = d
    *
    *
    */
    function addressData(address a, uint b, uint c) external view returns(address val) {
        assembly{
            mstore(0x0, a)
            mstore(0x20, b)
            mstore(0x40, c)
            val := sload(keccak256(0x0, 0x60))
        }
    }

    function addressData(address a, uint b, uint c, address d) external OnlyAccess {
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            mstore(0x40, c)
            sstore(keccak256(0x0, 0x60), d)
        }
    }

    /*
    *
    *
    stringData[a][b][c] = d
    *
    *
    */
    function stringData(address a, uint b) external view returns(string memory val) {
        assembly{
            mstore(0x0, a)
            mstore(0x20, b)
            let d := keccak256(0x0, 0x40)
            val := mload(0x40)
            mstore(0x40, add(val, 0x60))
            mstore(val, 0x40)
            mstore(add(val, 0x20), sload(d))
            mstore(add(val, 0x40), sload(add(d, 0x20)))
        }
    }

    function stringData(address a, uint b, string memory c) external OnlyAccess {
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            let d := keccak256(0x0, 0x40)
            sstore(d, mload(add(c, 0x20)))
            sstore(add(d, 0x20), mload(add(c, 0x40)))
        }
    }

    /*
    *
    *
    lists[a][b][c] = List(d, e);
    *
    *
    */
    function listData(address a, address b, uint c) external view returns(address d, uint e) {
        assembly{
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            let f := keccak256(0x80, 0x60)
            d := sload(f)
            e := sload(add(f, 0x20))
        }
    }

    function listData(address a, address b, uint c, address d, uint e) external OnlyAccess {
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
    *
    *
    _uintEnum[a][b].push(c);
    *
    *
    */
    function uintEnum(address a, address b) external view returns (uint[] memory val) {

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
    
    function uintEnum(address a, address b, uint c) external OnlyAccess {
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            let ptr := keccak256(0x0, 0x40)
            let len := sload(ptr)
            sstore(ptr, add(len, 0x1))
            mstore(0x0, ptr)
            sstore(add(keccak256(0x0, 0x20), mul(len, 0x1)), c)
        }
    }

    function uintEnumPop(address a, address b, uint c) external OnlyAccess {
        assembly {
            mstore(0x0, a)
            mstore(0x20, b)
            let ptr := keccak256(0x0, 0x40)
            let len := sload(ptr)
            if iszero(gt(len, c)) {
                revert(0x0, 0x0)
            }
            sstore(ptr, sub(len, 0x1))
            mstore(0x0, ptr)
            ptr := keccak256(0x0, 0x20)
            sstore(add(ptr, c), sload(add(ptr, sub(len, 0x1))))
        }
    }
    
}