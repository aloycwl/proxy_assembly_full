//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract Stringy {

    function substring() public pure returns (string memory result) {

        assembly {
            let str := "12345678901234567890123456789012"
            let len := 5

            let strPtr := add(str, 0x20)
            let subStrPtr := add(strPtr, 0x0)

            mstore(subStrPtr, len)

            mstore(result, add(len, 0x20))

            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                let char := mload(add(subStrPtr, i))
                mstore(add(result, add(i, 0x20)), char)
            }
        }

        return result;
    }


    function store_string() external {

        assembly {
            let str := "String valuessssssss"
            mstore(0x0, 0x20)
            mstore(0x20, 0x20)
            mstore(0x40, str)

            sstore(0x0, str)
        }

    }

    function fetch_string() external view returns(string memory) {

        assembly {
            
            mstore(0x0, 0x20)
            mstore(0x20, 0x40)
            mstore(0x40, sload(0x0))
            mstore(0x60, sload(0x0))
            mstore(0x80, sload(0x0))
            
            return(0x0, 0x100)
        }

    }

}