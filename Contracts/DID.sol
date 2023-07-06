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

    //DID需要变量和其它储存变量
    mapping(string  => address)                                             public did;
    mapping(address => mapping(address  => mapping(address  => uint)))      public uintData;
    mapping(address => mapping(uint     => mapping(uint     => address)))   public addressData;
    mapping(address => mapping(address  => mapping(uint     => string)))    public stringData;
    mapping(address => mapping(address  => uint[]))                         public uintEnum;
    mapping(address => mapping(address  => mapping(uint     => List)))      public lists;

    //持有权限者才能更新数据
    function updateDid(string calldata a, address b)                        external OnlyAccess {

        did[a]                                = b;

    }

    function updateString(address a, address b, uint c, string calldata d)  external OnlyAccess {

        stringData[a][b][c]                 = d;

    }

    function updateAddress(address a, uint b, uint c, address d)            external OnlyAccess {

        addressData[a][b][c]                   = d;

    }

    function updateUint(address a, address b, address c, uint d)            external OnlyAccess {

        uintData[a][b][c]                       = d;

    }

    //特别用于NFTMarket和ERC721的储存
    function updateList(address a, address b, uint c, address d, uint e)    external OnlyAccess {

        lists[a][b][c]                          = List(d, e);

    }

    function deleteList(address a, address b, uint c)                       external OnlyAccess {

        delete lists[a][b][c];

    }

    //数组只可以通过函数来调动
    function uintEnumData(address a, address b) public view returns(uint[] memory) {
    
        return uintEnum[a][b];
    }

    function pushUintEnum(address a, address b, uint c)                     external OnlyAccess {

        uintEnum[a][b].push                     (c);

    }

    function popUintEnum(address a, address b, uint c)                      external OnlyAccess {

        uint[] storage enumBal = uintEnum[a][b];
        uint bal               = enumBal.length;

        unchecked {

            for (uint i; i < bal; ++i)                              
                if (enumBal[i] == c) {

                    enumBal[i] = enumBal[bal - 1];
                    enumBal.pop();
                    break;

            }

        }

    }
    
}