// SPDX-License-Identifier:None
pragma solidity 0.8.23;
pragma abicoder v2;

import {Ownable} from "../Util/Ownable.sol";
import {Check} from "../Util/Check.sol";

contract GGC is Ownable, Check {

    event Transfer(address indexed, address indexed, uint);
    event Approval(address indexed, address indexed, uint);

    function name() external pure returns (string memory) { 
        assembly {
            mstore(0x80, 0x20)
            mstore(0xa0, 0x0e)
            mstore(0xc0, "Game Gold Coin")
            return(0x80, 0x60)
        }
    }

    function symbol() external pure returns (string memory) { 
        assembly {
            mstore(0x80, 0x20)
            mstore(0xa0, 0x03)
            mstore(0xc0, "GGC")
            return(0x80, 0x60)
        }
    }

    function decimals() external pure returns (uint) { 
        assembly {
            mstore(0x00, 0x12)
            return(0x00, 0x20)
        }
    }
    
    function totalSupply() external view returns (uint) { 
        assembly {
            mstore(0x00, sload(INF))
            return(0x00, 0x20)
        }
    }

    function allowance(address adr, address ad2) external view returns (uint) { 
        assembly {
            mstore(0x00, adr)
            mstore(0x20, ad2)
            mstore(0x00, sload(keccak256(0x00, 0x40)))
            return(0x00, 0x20)
        }
    }

    function balanceOf(address adr) external view returns (uint) { 
        assembly {
            mstore(0x00, adr)
            mstore(0x00, sload(keccak256(0x00, 0x20)))
            return(0x00, 0x20)
        }
    }

    function approve(address adr, uint amt) external returns (bool) { 
        assembly {
            mstore(0x00, caller())
            mstore(0x20, adr)
            sstore(keccak256(0x00, 0x40), amt)
            mstore(0x00, amt)
            log3(0x00, 0x20, EAP, caller(), adr)
        }
        return true;
    }

    function transfer(address adr, uint amt) external returns (bool) { 
        assembly {
            mstore(0x00, caller())
            let tmp := keccak256(0x00, 0x20)
            let bal := sload(tmp)
            if gt(amt, bal) { // require(balanceOf(msg.sender) >= amt)
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER2)
                revert(0x80, 0x64)
            }
            sstore(tmp, sub(bal, amt))
            mstore(0x00, adr)
            tmp := keccak256(0x00, 0x20)
            sstore(tmp, add(sload(tmp), amt))

            mstore(0x00, amt) // emit Transfer(adr, ad2, amt)
            log3(0x00, 0x20, ETF, caller(), adr)
        }
        isSuspended(msg.sender, adr);
        return true;
    }
    
    function transferFrom(address adr, address ad2, uint amt) public returns (bool) { 
        assembly {
            mstore(0x00, adr)
            let tmp := keccak256(0x00, 0x20)
            let bal := sload(tmp)
            mstore(0x00, adr)
            mstore(0x20, ad2)

            let ptr := keccak256(0x00, 0x40)
            let alw := sload(ptr)
            if or(gt(amt, bal), gt(amt, alw)) { // require(allowance >= amt)
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER2)
                revert(0x80, 0x64)
            }

            sstore(ptr, sub(alw, amt))
            sstore(tmp, sub(bal, amt))
            mstore(0x00, ad2)
            tmp := keccak256(0x00, 0x20)
            sstore(tmp, add(sload(tmp), amt))

            mstore(0x00, amt) // emit Transfer(adr, ad2, amt)
            log3(0x00, 0x20, ETF, caller(), adr) 
        }
        isSuspended(adr, ad2);
        return true;
    }

    function mint(address adr, uint amt) external onlyOwner {
        assembly {
            mstore(0x00, adr)
            let tmp := keccak256(0x00, 0x20)
            sstore(tmp, add(sload(tmp), amt))
            sstore(INF, add(sload(INF), amt))
            mstore(0x00, amt) // emit Transfer(adr, ad2, amt)
            log3(0x00, 0x20, ETF, 0x00, adr) 
        }
        isSuspended(adr);
    }
}