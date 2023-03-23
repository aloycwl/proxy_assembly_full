pragma solidity>0.8.0;//SPDX-License-Identifier:None



interface ERC20{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint);
    function totalSupply() external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function approve(address, uint) external returns (bool);
    function allowance(address, address) external view returns (uint);

    function ToggleSuspend()external

}

contract ERC20AC{
    ERC20 m;
    constructor(address a){
        m = ERC20(a);
    }
    function name() external view returns (string memory){ return m.name(); }
    function symbol() external view returns (string memory){ return m.symbol(); }
    function decimals() external view returns (uint){ return m.decimals(); }
    function totalSupply() external view returns (uint){ return m.totalSupply(); }
    function balanceOf(address a) external view returns (uint){ return m.balanceOf(a); }
    function transfer(address a, uint b) external returns (bool){ return m.transfer(a, b); }
    function transferFrom(address a, address b, uint c) external returns (bool) { return m.transferFrom(a, b, c); }
    function approve(address a, uint b) external returns (bool){ return m.approve(a, b); }
    function allowance(address a, address b) external view returns (uint){ return m.allowance(a, b); }


}
