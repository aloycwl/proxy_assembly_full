//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;


contract TestCall {


    function pay() external payable {
        assembly {
            let success := call(gas(), 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, selfbalance(), 0, 0, 0, 0)
        }
    }
}