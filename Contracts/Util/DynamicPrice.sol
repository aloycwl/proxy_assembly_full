//SPDX-License-Identifier:None
pragma solidity 0.8.18;

contract DynamicPrice{

    struct List{

        address tokenAddr;
        uint    price;

    }

    mapping(uint => List)   public  list;

    //根据合约类型和级别设置定价
    function setList(uint _list, address tokenAddr, uint price) internal {

        List storage li = list[_list];
        (li.tokenAddr, li.price) = (tokenAddr, price);

    }

    //调变量
    function getList(uint _list) internal view returns(address, uint){

        List storage li = list[_list];
        return (li.tokenAddr, li.price);

    }

}