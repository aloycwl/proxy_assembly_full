//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;



contract CustomError {

    error Err(bytes32);

    function f() external pure {
        
        assembly {
            mstore(0, shl(0xe0, 0x5b4fb734))
            mstore(4, 0x1)
            revert(0, 0x24)
        }
    }

}