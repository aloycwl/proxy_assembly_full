//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract ERC20AC{

    event Transfer(address indexed from,  address indexed to,      uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint)                     public balanceOf;
    uint constant                                public decimals    = 18;
    uint                                         public totalSupply = 1e24;
    string constant                              public name        = "Name";
    string constant                              public symbol      = "SYM";

    function approve (address to, uint amt) external returns(bool) {
        
        emit Approval(msg.sender, to, allowance[msg.sender][to] = amt);
        return true;

    }

    function transfer (address to, uint amt) external returns(bool) {

        return transferFrom(msg.sender, to, amt);

    }
    
    function transferFrom (address a, address b, uint c) public returns (bool) {

        unchecked {

            uint allow = allowance[a][b];    

            assert(balanceOf[a] >= c && (a == msg.sender || allow >= c));

            if(allow >= c) allowance[a][b] -= c;
            (balanceOf[a] -= c, balanceOf[b] += c);

            emit Transfer(a, b, c);
            return true;

        }

    }

}