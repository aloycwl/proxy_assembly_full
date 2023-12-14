// SPDX-License-Identifier: None
pragma solidity 0.8.23;

import {Hashes} from "../Util/Hashes.sol";

contract SubNode is Hashes {
    bytes32 constant internal OWO = 0x6352211e00000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal TTF = 0xa9059cbb00000000000000000000000000000000000000000000000000000000;

    constructor(address adr) {
        assembly {
            sstore(OWO, caller())
            sstore(TTF, adr)
        }
    }

    function transfer(address adr, uint amt) external {
        assembly { 
            if iszero(eq(sload(OWO), caller())) {
                revert(0x00, 0x00)
            }
            mstore(0x80, TTF) // ERC20(GGC).transfer(msg.sender, amt)
            mstore(0x84, adr)
            mstore(0xa4, amt)
            pop(call(gas(), sload(TTF), 0x00, 0x80, 0x44, 0x00, 0x00))
        }
    }
}

contract AddSubNodes is Hashes {
    
    mapping(address => address) public users;
    address[] public subNodes;
    
    function startSubNodes(uint num) external {
        uint bal;
        address ggc;

        assembly { 
            mstore(0x00, BAL) // ERC20(GGC).balanceOf(address(this))
            mstore(0x04, address())
            pop(staticcall(gas(), sload(TTF), 0x00, 0x24, 0x00, 0x20))
            bal := mload(0x00)
            ggc := sload(TTF)
        }

        uint amt = bal / num; // 每节点分多少币

        for (uint i; i < num; ++i) {
            address adr = address(new SubNode(ggc));
            subNodes.push(adr);
            assembly { 
                mstore(0x80, TTF) // ERC20(GGC).transfer(msg.sender, amt)
                mstore(0x84, adr)
                mstore(0xa4, amt)
                pop(call(gas(), sload(TTF), 0x00, 0x80, 0x44, 0x00, 0x00))
            }
        }
    }

    function getSubNodes() private returns(address adr)  {
        if(users[msg.sender] == address(0)) {
            adr = subNodes[uint(keccak256(abi.encodePacked(block.timestamp))) % subNodes.length];
            users[msg.sender] = adr;
        } else adr = users[msg.sender];
    }
}