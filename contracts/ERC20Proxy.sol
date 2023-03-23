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

    function SetAccess(address a, bool b)external;
    function ToggleSuspend()external;
    function ToggleBlock(address addr)external;
    function Burn(uint amt)external;
}

contract ERC20AC{
    ERC20 m;
    address private _owner;
    constructor(address a){
        (m, _owner) = (ERC20(a), msg.sender);
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

    function SetAccess(address a, bool b)external{ m.SetAccess(a, b); }
    function ToggleSuspend()external{ m.ToggleSuspend(); }
    function ToggleBlock(address a)external{ m.ToggleBlock(a); }
    function Burn(uint a)external{ m.Burn(a); }

    function NewAddress(address a)external{
        require(msg.sender == _owner);
        m = ERC20(a);
    }
}
