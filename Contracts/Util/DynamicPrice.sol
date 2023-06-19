//SPDX-License-Identifier:None
pragma solidity ^0.8.0;

import "Contracts/ERC20.sol";

contract DynamicPrice {

    address public  owner;
    Proxy private iProxy;
    //mapping(address => mapping(uint => List))   public lists;

    constructor (address proxy) {

        owner = msg.sender;
        iProxy = Proxy(proxy);

    }

    function pay(address contAddr, uint _list, address to, uint fee) internal {

        (address tokenAddr, uint price) = DID(iProxy.addrs(3)).lists(contAddr, _list);

        unchecked {

            if (price > 0) 
                    //如果不指定地址，则转入主币，否则从合约地址转入
                    if (tokenAddr == address(0)) {

                        require(msg.value >= price,                     "Insufficient amount");
                        payable(to).transfer(address(this).balance * (1e4 - fee) / 1e4);

                    } else {

                        //ERC20需要授权
                        ERC20 iERC20 = ERC20(tokenAddr);
                        require(iERC20.transfer(address(this), price),  "Insufficient amount");
                        iERC20.transfer(to, iERC20.balanceOf(address(this)) * (1e4 - fee) / 1e4);

                    }

        }

    }

}