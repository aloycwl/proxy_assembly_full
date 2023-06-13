//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "/Contracts/Interfaces.sol";

contract DynamicPrice {

    struct List {

        address tokenAddr;
        uint    price;

    }

    address                                     public owner;
    mapping(address => mapping(uint => List))   public lists;

    function pay(address contAddr, uint _list, address to, uint fee) internal {

        List storage li = lists[contAddr][_list];
        (address tokenAddr, uint price) = (li.tokenAddr, li.price);

        unchecked {

            if (price > 0) 
                    //如果不指定地址，则转入主币，否则从合约地址转入
                    if (tokenAddr == address(0)) {

                        require(msg.value >= price,                     "Insufficient amount");
                        payable(to).transfer(address(this).balance * (1e4 - fee) / 1e4);

                    } else {

                        //ERC20需要授权
                        IERC20 iERC20 = IERC20(tokenAddr);
                        require(iERC20.transfer(address(this), price),  "Insufficient amount");
                        iERC20.transfer(to, iERC20.balanceOf(address(this)) * (1e4 - fee) / 1e4);

                    }

        }

    }

}