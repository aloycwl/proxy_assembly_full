//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;


contract TestCall {

    function getSelector(string memory s) external pure returns (bytes4) {
        //return bytes4(keccak256("listData(address,address,uint256)"));
        return bytes4(keccak256(abi.encodePacked(s)));
        //461BCD
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
        address contAddr = 0xf2B1114C644cBb3fF63Bf1dD284c8Cd716e95BE9;
        uint _list = 1;
        address did = 0xf8e81D47203A594245E36C48e151709F0C19fBe8;

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0xdf0188db)) // listData(address,address,uint256)
            mstore(add(ptr, 0x04), contAddr)
            mstore(add(ptr, 0x24), contAddr)
            mstore(add(ptr, 0x44), _list)
            pop(staticcall(gas(), did, ptr, 0x64, 0x0, 0x40))
            a := mload(0x0)
            b := mload(0x20)
        }
    }

}