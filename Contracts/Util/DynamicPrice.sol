//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "/Contracts/Interfaces.sol";
import "/Contracts/Util/UintLib.sol";

contract DynamicPrice {

    struct List {

        address tokenAddr;
        uint    price;

    }

    using UintLib for uint;

    mapping(uint => List)   public  list;

    //根据合约类型和级别设置定价
    function setList(uint _list, address tokenAddr, uint price) internal {

        List storage li = list[_list];
        (li.tokenAddr, li.price) = (tokenAddr, price);

    }

    //调变量
    function getList(uint _list) public view returns(address, uint) {

        List storage li = list[_list];
        return (li.tokenAddr, li.price);

    }

    function pay(uint _list, address to, uint fee) internal {

        (address tokenAddr, uint price) = getList(_list);

        if (price > 0) 
                //如果不指定地址，则转入主币，否则从合约地址转入
                if (tokenAddr == address(0)) {

                    require(msg.value >= price, "Insufficient amount");
                    payable(to).transfer(address(this).balance.minusPercent(fee));

                } else {

                    //ERC20需要授权
                    IERC20 iERC20 = IERC20(tokenAddr);
                    require(iERC20.transfer(address(this), price), "Insufficient amount");
                    iERC20.transfer(to, iERC20.balanceOf(address(this)).minusPercent(fee));

                }

    }

}