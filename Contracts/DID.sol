//SPDX-License-Identifier:None
pragma solidity ^0.8.0;

import "Contracts/Util/Access.sol";
import "Contracts/Util/LibUint.sol";

//储存和去中心化身份合约
contract DID is Access {

    using LibUint for uint;

    //DID需要变量和其它储存变量
    mapping(string  => address)                                                     public did;
    mapping(address => mapping(uint     => uint))                                   public uintData;
    mapping(address => mapping(address  => mapping(uint => uint)))                  public uintAddrData;
    mapping(address => mapping(uint  => mapping(uint => address)))                  public addressData;
    mapping(address => mapping(address  => mapping(uint => string)))                public stringData;
    mapping(address => mapping(uint     => uint[]))                                 public uintEnum;

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

    function updateUint (address addr, uint index, uint val)                        external OnlyAccess {

        uintData[addr][index]                   = val;

    }

    function updateUintAddr (address addr1, address addr2, uint index, uint val)    external OnlyAccess {

        uintAddrData[addr1][addr2][index]       = val;

    }

    //数组只可以通过函数来调动
    function uintEnumData(address addr, uint index) public view returns (uint[] memory) {
    
        return uintEnum[addr][index];
    }

    function pushUintEnum (address addr, uint index, uint val)                      external OnlyAccess {

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