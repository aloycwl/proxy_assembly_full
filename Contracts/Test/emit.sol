//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;


contract test1 {

    event Transfers(address indexed from, address indexed to, uint indexed id);

    function test() external {
        assembly {
            mstore(0x0, 0x37)
            log4(0x0, 0x20, 0xb6d4421aa56ed943c79643412fad6392773cd6ccb8e10c96f93f1970051d4f40, 0x37, origin(), origin())
        }

        //emit Transfers(msg.sender, msg.sender, 0x37);
    }
}