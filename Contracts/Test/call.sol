//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;


contract TestCall {


    

    function getSelector() external pure returns (bytes4) {
        //return bytes4(keccak256("transferFrom(address,address,uint256)"));
        return bytes4(keccak256("listData(address,address,uint256)"));
    }

    function getBalance() external view returns(uint val) {
        address from = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        address tokenAddr = 0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99;

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x70a0823100000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), from)
            pop(staticcall(gas(), tokenAddr, ptr, 0x24, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function getListData() external view returns(address a, uint b) {
        //address a = address(this);
        address contAddr = 0xf2B1114C644cBb3fF63Bf1dD284c8Cd716e95BE9;
        uint _list = 1;
        address did = 0xF27374C91BF602603AC5C9DaCC19BE431E3501cb;

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0xdf0188db00000000000000000000000000000000000000000000000000000000)
            //mstore(ptr, shl(224, 3741419739))
            mstore(add(ptr, 0x04), contAddr)
            mstore(add(ptr, 0x24), contAddr)
            mstore(add(ptr, 0x44), _list)
            pop(staticcall(gas(), did, ptr, 0x64, 0x0, 0x40))
            a := mload(0x0)
            b := mload(0x20)
        }
    }

}