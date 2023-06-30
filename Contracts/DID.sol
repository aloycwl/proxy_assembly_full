//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import "Contracts/Util/Access.sol";

struct List {

    address tokenAddr;
    uint    price;

}

//储存和去中心化身份合约
contract DID is Access {

    //DID需要变量和其它储存变量
    mapping(string  => address)                                                     public did;
    mapping(address => mapping(address  => mapping(address  => uint)))              public uintData;
    mapping(address => mapping(uint     => mapping(uint     => address)))           public addressData;
    mapping(address => mapping(address  => mapping(uint     => string)))            public stringData;
    mapping(address => mapping(address  => uint[]))                                 public uintEnum;
    mapping(address => mapping(address  => mapping(uint     => List)))              public lists;

    //持有权限者才能更新数据
    function updateDid (string calldata str, address val)                           external OnlyAccess {

        did[str]                                = val;

    }

    function updateString (address a, address b, uint index, string calldata val)   external OnlyAccess {

        stringData[a][b][index]                 = val;

    }

    function updateAddress (address a, uint b, uint id, address val)                external OnlyAccess {

        addressData[a][b][id]                   = val;

    }

    function updateUint (address a, address b, address c, uint val)                 external OnlyAccess {

        uintData[a][b][c]                       = val;

    }

    //特别用于NFTMarket和ERC721的储存
    function updateList (address a, address b, uint c, List calldata val)           external OnlyAccess {

        lists[a][b][c]                          = val;

    }

    function deleteList (address a, address b, uint c)                              external OnlyAccess {

        delete lists[a][b][c];

    }

    //数组只可以通过函数来调动
    function uintEnumData (address a, address b) public view returns (uint[] memory) {
    
        return uintEnum[a][b];
    }

    function pushUintEnum (address a, address b, uint val)                          external OnlyAccess {

        uintEnum[a][b].push                     (val);

    }

    function popUintEnum (address a, address b, uint val)                           external OnlyAccess {

        uint[] storage enumBal = uintEnum[a][b];
        uint bal               = enumBal.length;

        unchecked {

            for (uint i; i < bal; ++i)                                  
                if (enumBal[i] == val) {

                    enumBal[i] = enumBal[bal - 1];
                    enumBal.pop();
                    break;

            }

        }

    }
    
}