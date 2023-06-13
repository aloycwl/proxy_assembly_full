//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "Contracts/Util/Access.sol";
import "Contracts/Util/LibUint.sol";
import "Contracts/Interfaces.sol";

//储存和去中心化身份合约
contract DID is IDID, Access {

    using LibUint for uint;

    //DID需要变量和其它储存变量
    mapping(string  => address)                                                     public did;
    mapping(address => mapping(uint     => mapping(uint => string)))                public stringData;
    mapping(address => mapping(uint     => address))                                public addressData;
    mapping(address => mapping(uint     => uint))                                   public uintData;
    mapping(address => mapping(address  => mapping(uint => uint)))                  public uintAddrData;
    mapping(address => mapping(uint     => uint[]))                                 public uintEnum;
    mapping(uint    => mapping(uint     => address))                                public uint2Data;

    //数组只可以通过函数来调动
    function uintEnumData(address addr, uint index) public view returns (uint[] memory) {
    
        return uintEnum[addr][index];
    }
    
    //持有权限者才能更新数据
    function updateDid(string calldata str, address val)                            external OnlyAccess {

        did[str]                                = val;

    }

    function updateString(address addr, uint id, uint index, string calldata val)   external OnlyAccess {

        stringData[addr][id][index]             = val;

    }

    function updateAddress(address addr, uint index, address val)                   external OnlyAccess {

        addressData[addr][index]                = val;

    }

    function updateUint(address addr, uint index, uint val)                         external OnlyAccess {

        uintData[addr][index]                   = val;

    }

    function updateUintAddr(address addr1, address addr2, uint index, uint val)     external OnlyAccess {

        uintAddrData[addr1][addr2][index]       = val;

    }

    function updateUint2(uint id, uint index, address val)                          external OnlyAccess {

        uint2Data[id][index]                    = val;

    }

    function pushUintEnum(address addr, uint index, uint val)                       external OnlyAccess {

        uintEnum[addr][index].push              (val);

    }

    function popUintEnum(address addr, uint index, uint val)                        external OnlyAccess {

        (uint bal, uint[] storage enumBal) = (uintData[addr][index], uintEnum[addr][index]);

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