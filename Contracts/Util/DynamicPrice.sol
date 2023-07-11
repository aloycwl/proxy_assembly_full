//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import {DID, ERC20, Access} from "Contracts/ERC20.sol";

contract DynamicPrice {

    DID     private iDID;
    address public owner;

    constructor(address did) {

        (iDID, owner) = (DID(did), msg.sender);

        assembly {
            sstore(0x20, origin())
        }

    }

    /*function owner() public view returns (address a) {

        assembly {
            a := sload(0x20)
        }

    }*/

    function pay(address contAddr, uint _list, address to, uint fee) internal {

        (address tokenAddr, uint price) = iDID.listData(address(this), contAddr, _list);

        unchecked {

            if(price > 0) {

                if(fee > 0) //price *= (1e4 - fee) / 1e4;

                    assembly {
                        price := div(mul(price, sub(0x2710, fee)), 0x2710)
                    }

                
                //如果不指定地址，则转入主币，否则从合约地址转入
                if(tokenAddr == address(0)) {

                    require(msg.value >= price,                                    "04");
                    payable(to).transfer(price);
                    payable(this.owner()).transfer(address(this).balance);

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