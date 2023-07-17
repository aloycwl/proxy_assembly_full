//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;


contract TestCall {

    error Err(bytes32);

    function getSelector(string memory s) external pure returns (bytes4) {
        //return bytes4(keccak256("listData(address,address,uint256)"));
        return bytes4(keccak256(abi.encodePacked(s)));
    }

    function getBalance() external view returns(uint val) {
        address from = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        address tokenAddr = 0x38cB7800C3Fddb8dda074C1c650A155154924C73;

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0x70a08231))
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

    function TTF() external {
        address tokenAddr = 0x1911b1a3ed36d3593BB7d0ca68A3bE5a59BE49dC;
        address to = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        uint price = 1000;
        uint fee = 400;

        assembly {
            sstore(0x1, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)
            function x(cod) {
                mstore(0x0, shl(0xe0, 0x5b4fb734))
                mstore(0x4, cod)
                revert(0x0, 0x24)
            }

            let ptr := mload(0x40)
            
            mstore(ptr, shl(0xe0, 0x23b872dd))
            mstore(add(ptr, 0x04), origin())
            mstore(add(ptr, 0x24), to)
            mstore(add(ptr, 0x44), fee)

            if iszero(call(gas(), tokenAddr, 0x0, ptr, 0x64, 0x0, 0x0)) {
                x(0x5)
            }
            
            mstore(add(ptr, 0x24), sload(0x1))
            mstore(add(ptr, 0x44), sub(price, fee))
            if iszero(call(gas(), tokenAddr, 0x0, ptr, 0x64, 0x0, 0x0)) {
                x(0x5)
            }
        }
    }
}