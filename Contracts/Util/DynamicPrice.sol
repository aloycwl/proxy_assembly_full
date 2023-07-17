//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {DID, ERC20, Access} from "Contracts/ERC20.sol";

contract DynamicPrice {

    DID private iDID;

    constructor(address did) {
        iDID = DID(did);

        assembly {
            sstore(0x1, origin())
        }
    }

    function owner() public view returns (address a) {
        assembly {
            a := sload(0x1)
        }
    }

    function pay(address contAddr, uint _list, address to, uint fee) internal {
        (address tokenAddr, uint price) = iDID.listData(address(this), contAddr, _list);
        unchecked {
            if(price > 0) {
                if(fee > 0) //price *= (1e4 - fee) / 1e4;
                    assembly {
                        price := div(mul(price, sub(0x2710, fee)), 0x2710)
                    }
                // 如果不指定地址，则转入主币，否则从合约地址转入
                if(tokenAddr == address(0)) {

                    //require(msg.value >= price, "04");
                    //payable(to).transfer(price);
                    //payable(this.owner()).transfer(address(this).balance);

                    assembly {
                        if lt(price, callvalue()) { //require(msg.value >= price, "04")
                            mstore(0x80, shl(229, 4594637)) 
                            mstore(0x84, 0x20) 
                            mstore(0xA4, 0x2)
                            mstore(0xC4, "04")
                            revert(0x80, 0x64)
                        }
                        // 先还卖家，再还行政
                        pop(call(gas(), to, price, 0x0, 0x0, 0x0, 0x0))
                        pop(call(gas(), sload(0x1), selfbalance(), 0x0, 0x0, 0x0, 0x0))
                    }

                } else {
                    //ERC20需要授权
                    ERC20 iERC20 = ERC20(tokenAddr);
                    require(iERC20.transferFrom(msg.sender, address(this), price), "05");
                    iERC20.transferFrom(address(this), to, price);
                    iERC20.transferFrom(address(this), this.owner(), iERC20.balanceOf(address(this)));
                }
            }
        }
    }
}