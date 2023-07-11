//SPDX-License-Identifier:None
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
            mstore(0x80, 0x0)
            mstore(0xa0, 0x0)
            mstore(0xc0, 0x0)
            mstore(0xe0, 0x2)
            sstore(keccak256(0x80, 0x80), origin())
        }
    }

    mapping(address => mapping(uint     => string)) private _stringData;
    mapping(address => mapping(address  => mapping(uint     => List)))      public lists;
    mapping(address => mapping(address  => uint[]))                         public uintEnum;

    //数组只可以通过函数来调动
    function uintEnumData(address a, address b) public view returns(uint[] memory) {
        return uintEnum[a][b];
    }

    /*
    *
    *
    did[a] = b
    *
    *
    */
    function did(string memory a) external view returns(address val) {
        assembly{
            val := sload(keccak256(a, 0x20))
        }
    }

    function updateDid(string memory a, address b) external OnlyAccess {
        assembly {
            sstore(keccak256(a, 0x20), b)
        }
    }

    /*
    *
    *
    uintData[a][b][c] = d //0x1
    *
    *
    */
    function uintData(address a, address b, address c) external view returns(uint val) {
        assembly{
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            mstore(0xe0, 0x1)
            val := sload(keccak256(0x80, 0x80))
        }
    }

    function updateUint(address a, address b, address c, uint d) external OnlyAccess {
        assembly {
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            mstore(0xe0, 0x1)
            sstore(keccak256(0x80, 0x80), d)
        }
    }

    /*
    *
    *
    addressData[a][b][c] = d //0x2
    *
    *
    */
    function addressData(address a, uint b, uint c) external view returns(address val) {
        assembly{
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            mstore(0xe0, 0x2)
            val := sload(keccak256(0x80, 0x80))
        }
    }

    function updateAddress(address a, uint b, uint c, address d) external OnlyAccess {
        assembly {
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            mstore(0xe0, 0x2)
            sstore(keccak256(0x80, 0x80), d)
        }
    }

    /*
    *
    *
    stringData[a][b][c] = d //0x3
    *
    *
    */
    function stringData(address a, uint b) external view returns(string memory val) {
        /*assembly{
            mstore(0x80, a)
            mstore(0xa0, b)
            val := sload(keccak256(0x80, 0x60))
        }*/
        val = _stringData[a][b];
    }

    function updateString(address a, uint b, string memory c) external OnlyAccess {
        /*assembly {
            mstore(0x80, a)
            mstore(0xa0, b)
            sstore(keccak256(0x80, 0x60), c)
        }*/
        _stringData[a][b] = c;
    }

    function test(address a, uint b, uint c) external pure returns(bytes32 val) {
        assembly {
            mstore(0x80, a)
            mstore(0xa0, b)
            mstore(0xc0, c)
            mstore(0xe0, 0x2)
            val := keccak256(0x80, 0x80)
            //0x0000000000000000000000000000000000000000
            //0x246ab83ea3b026af046bc19abf7ac0980e6ee81bae691f59be6bdf565d16192c
            //0xff496e08a30e0406970dcb66bf9f6ada8a180c31ceba28262332b01aa1921c70
        }
    }

    

    

    

    //特别用于NFTMarket和ERC721的储存
    function updateList(address a, address b, uint c, address d, uint e)    external OnlyAccess {

        lists[a][b][c]          = List(d, e);

    }

    function deleteList(address a, address b, uint c)                       external OnlyAccess {

        delete lists[a][b][c];

    }

    function pushUintEnum(address a, address b, uint c)                     external OnlyAccess {

        uintEnum[a][b].push(c);

    }

    function popUintEnum(address a, address b, uint c)                      external OnlyAccess {

        uint[] storage enumBal = uintEnum[a][b];
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