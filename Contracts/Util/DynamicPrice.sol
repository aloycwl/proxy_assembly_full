//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "/Contracts/Interfaces.sol";
import "/Contracts/Util/LibUint.sol";

contract DynamicPrice {

    struct List {

        address tokenAddr;
        uint    price;

    }

    using LibUint for uint;

    address                                     public owner;
    mapping(address => mapping(uint => List))   public lists;

    //根据合约类型和级别设置定价
    function setList(address contAddr, uint _list, address tokenAddr, uint price) internal {

        List storage li = lists[contAddr][_list];
        (li.tokenAddr, li.price) = (tokenAddr, price);

    }

    //调变量
    function getList(address contAddr, uint _list) public view returns(address, uint) {

        List storage li = lists[contAddr][_list];
        return (li.tokenAddr, li.price);

    }

    function pay(address contAddr, uint _list, address to, uint fee) internal {

        (address tokenAddr, uint price) = getList(contAddr, _list);

        if (price > 0) 
                //如果不指定地址，则转入主币，否则从合约地址转入
                if (tokenAddr == address(0)) {

                    require(msg.value >= price,                     "Insufficient amount");
                    payable(to).transfer(address(this).balance.minusPercent(fee));

                } else {

                    //ERC20需要授权
                    IERC20 iERC20 = IERC20(tokenAddr);
                    require(iERC20.transfer(address(this), price),  "Insufficient amount");
                    iERC20.transfer(to, iERC20.balanceOf(address(this)).minusPercent(fee));

                }

    }

}