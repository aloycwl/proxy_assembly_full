//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "/Contracts/Interfaces.sol";
//import "/Contracts/Util/LibUint.sol";

contract DynamicPrice {

    struct List {

        address tokenAddr;
        uint    price;

    }

    //using LibUint for uint;

    address                                     public owner;
    mapping(address => mapping(uint => List))   public lists;

    function minusPercent(uint a, uint b) internal pure returns (uint) {

        unchecked {

            return a * (1e4 - b) / 1e4;
        }

    }

    function pay(address contAddr, uint _list, address to, uint fee) internal {

        List storage li = lists[contAddr][_list];
        (address tokenAddr, uint price) = (li.tokenAddr, li.price);

        if (price > 0) 
                //如果不指定地址，则转入主币，否则从合约地址转入
                if (tokenAddr == address(0)) {

                    require(msg.value >= price,                     "Insufficient amount");
                    payable(to).transfer(minusPercent(address(this).balance,fee));

                } else {

                    //ERC20需要授权
                    IERC20 iERC20 = IERC20(tokenAddr);
                    require(iERC20.transfer(address(this), price),  "Insufficient amount");
                    iERC20.transfer(to, minusPercent(iERC20.balanceOf(address(this)),fee));

                }

    }

}