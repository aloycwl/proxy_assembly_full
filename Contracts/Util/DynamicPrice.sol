//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import {DID, Proxy, ERC20, Access} from "Contracts/ERC20.sol";
import {IERC721, IERC721Metadata}  from "Contracts/Interfaces.sol";

contract DynamicPrice {

    address public  owner;
    Proxy   private iProxy;

    constructor (address proxy) {

        owner = msg.sender;
        iProxy = Proxy(proxy);

    }

    function pay(address contAddr, uint _list, address to, uint fee) internal {

        (address tokenAddr, uint price) = DID(iProxy.addrs(3)).lists(address(this), contAddr, _list);

        unchecked {

            if (price > 0) 
                
                //如果不指定地址，则转入主币，否则从合约地址转入
                if (tokenAddr == address(0)) {

                    require(msg.value >= price,                                     "Insufficient $");
                    payable(to).transfer(address(this).balance * (1e4 - fee) / 1e4);
                    payable(owner).transfer(address(this).balance);

                } else {

                    //ERC20需要授权
                    ERC20 iERC20 = ERC20(tokenAddr);
                    require(iERC20.transferFrom(msg.sender, address(this), price),  "Insufficient ERC20");
                    iERC20.transferFrom(address(this), to, iERC20.balanceOf(address(this)) * (1e4 - fee) / 1e4);
                    iERC20.transferFrom(address(this), owner, iERC20.balanceOf(address(this)));

                }

        }

    }

}