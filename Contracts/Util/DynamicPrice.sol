//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import {DID, ERC20, Access}       from "Contracts/ERC20.sol";
import {IERC721, IERC721Metadata} from "Contracts/Interfaces.sol";

contract DynamicPrice {

    address public  owner;
    DID     private iDID;

    constructor(address did) {

        (owner, iDID) = (msg.sender, DID(did));

    }

    function pay(address contAddr, uint _list, address to, uint fee) internal {

        (address tokenAddr, uint price) = iDID.lists(address(this), contAddr, _list);

        unchecked {

            if(price > 0) 
                
                //如果不指定地址，则转入主币，否则从合约地址转入
                if(tokenAddr == address(0)) {

                    require(msg.value >= price,                                    "Insufficient coin");
                    payable(to).transfer(price * (1e4 - fee) / 1e4);
                    payable(owner).transfer(address(this).balance);

                } else {

                    //ERC20需要授权
                    ERC20 iERC20 = ERC20(tokenAddr);
                    require(iERC20.transferFrom(msg.sender, address(this), price), "Insufficient ERC20");
                    iERC20.transferFrom(address(this), to, price * (1e4 - fee) / 1e4);
                    iERC20.transferFrom(address(this), owner, iERC20.balanceOf(address(this)));

                }

        }

    }

}