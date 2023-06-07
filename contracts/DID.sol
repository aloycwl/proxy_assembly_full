//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Util.sol";

//储存和去中心化身份合约
contract DID is /*IDID,*/ Access {

    //DID需要变量
    mapping(string => address)                                                      public did;
    mapping(address => mapping(uint => string))                                     public stringData;
    mapping(address => mapping(uint => address))                                    public addressData;
    mapping(address => mapping(uint => uint))                                       public uintData;
    mapping(address => mapping(address => mapping(uint => uint)))                   public uintAddressData;
    mapping(address => mapping(uint => uint[]))                                     public uintEnumData;

    //其它储存变量
    mapping(uint => mapping(uint => address))                                       public uint2Data;
    
    //持有权限者才能更新数据
    function updateDid(string calldata str, address val)                            external OnlyAccess {

        did[str]                                = val;

    }

    function updateString(address addr, uint index, string calldata val)            external OnlyAccess {

        stringData[addr][index]                 = val;

    }

    function updateAddress(address addr, uint index, address val)                   external OnlyAccess {

        addressData[addr][index]                = val;

    }

    function updateUint(address addr, uint index, uint val)                         external OnlyAccess {

        uintData[addr][index]                   = val;

    }

    function updateUintAddress(address addr1, address addr2, uint index, uint val)  external OnlyAccess {

        uintAddressData[addr1][addr2][index]    = val;

    }

    function updateUint2(uint id, uint index, address val)                          external OnlyAccess {

        uint2Data[id][index]                    = val;

    }

    function pushUintEnum(address addr, uint index, uint val)                       external OnlyAccess {

        uintEnumData[addr][index].push          (val);

    }

    function popUintEnum(address addr, uint index, uint val)                        external OnlyAccess {

        (uint bal, uint[] storage enumBal) = (uintData[addr][index], uintEnumData[addr][index]);

        for (uint i; i < bal; ++i)                                  
            if (enumBal[i] == val) {

                enumBal[i] = enumBal[bal - 1];
                enumBal.pop();
                break;

            }

    }
    
}