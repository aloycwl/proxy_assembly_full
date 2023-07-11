//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Access} from "Contracts/Util/Access.sol";

struct List {
    address tokenAddr;
    uint    price;
}

//储存和去中心化身份合约
contract DID is Access {

    //设置签名人
    constructor() {
        assembly {
            mstore(0x0, 0x0)
            mstore(0x20, 0x0)
            mstore(0x40, 0x0)
            sstore(keccak256(0x0, 0x60), origin())
        }
    }

    /*
    *
    *
    did[a] = b
    *
    * 
    0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
    0xd833147d7dc355ba459fc788f669e58cfaf9dc25ddcd0702e87d69c7b5124289
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

    mapping(address => mapping(address  => uint[]))                         private _uintEnum;

    //数组只可以通过函数来调动
    function uintEnum(address a, address b) public view returns(uint[] memory) {
        return _uintEnum[a][b];
    }

    function UintEnumPush(address a, address b, uint c)                     external OnlyAccess {

        _uintEnum[a][b].push(c);

    }

    function uintEnumPop(address a, address b, uint c)                      external OnlyAccess {

        uint[] storage enumBal = _uintEnum[a][b];
        uint bal               = enumBal.length;

        unchecked {

            for (uint i; i < bal; ++i)                              
                if (enumBal[i] == c) {

                    enumBal[i] = enumBal[bal - 0x01];
                    enumBal.pop();
                    break;

                }

        }

    }
    
}