//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Access}    from "Contracts/DID.sol";
import {Sign, DID} from "Contracts/Util/Sign.sol";

//代币合约
contract ERC20 is Access, Sign {

    event Transfer (address indexed from, address indexed to, uint amt);
    event Approval (address indexed from, address indexed to, uint amt);
    uint public suspended; 

    //ERC20标准函数 
    constructor(address did, string memory nam, string memory sym) Sign(did) {
        assembly {
            sstore(0x2, mload(add(nam, 0x20)))
            sstore(0x3, mload(add(sym, 0x20)))
        }                                   
    }

    function decimals() external pure returns(uint val) {
        assembly {
            val := 0x12
        }
    }

    function totalSupply() external view returns(uint val) {
        assembly {
            val := sload(0x4)
        }
    }

    function name() external view returns(string memory val) {
        assembly {
            val := mload(0x40)
            mstore(0x40, add(val, 0x40))
            mstore(val, 0x20)
            mstore(add(val, 0x20), sload(0x2))
        }
    }

    function symbol() external view returns(string memory val) {
        assembly {
            val := mload(0x40)
            mstore(0x40, add(val, 0x40))
            mstore(val, 0x20)
            mstore(add(val, 0x20), sload(0x3))
        }
    }

    function balanceOf(address addr) public view returns(uint) {
        return iDID.uintData(address(this), addr, address(0));
    }

    function allowance(address from, address to) public view returns(uint) {
        return iDID.uintData(address(this), from, to);
    }

    function approve(address to, uint amt) public returns(bool) {
        iDID.uintData(address(this), msg.sender, to, amt);
        assembly {
            mstore(0x0, amt)
            log3(0x0, 0x20, 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925, caller(), to)
        }
        return true;
    }

    function transfer(address to, uint amt) external returns(bool) {
        return transferFrom(msg.sender, to, amt);
    }

    function transferFrom(address from, address to, uint amt) public returns(bool) {
        unchecked {
            (uint approveAmt, uint balanceFrom, uint u1, uint u2) = (allowance(from, to), balanceOf(from), 
                iDID.uintData(address(0), from, address(0)), iDID.uintData(address(0), to, address(0)));
            bool isApproved;

            assembly {
                isApproved := iszero(gt(amt, approveAmt))
                function x(con, str) {
                    if gt(con, 0) {
                        mstore(0x80, shl(229, 4594637)) 
                        mstore(0x84, 0x20) 
                        mstore(0xA4, 0x2)
                        mstore(0xC4, str)
                        revert(0x80, 0x64)
                    }
                }
                x(or(gt(u1, 0), gt(u2, 0)), "07") //u1 == 0 && u2 == 0
                x(gt(sload(0x1), 0), "08") //suspended == 0
                x(gt(amt, balanceFrom), "09") //balanceFrom >= amt
                x(and(iszero(eq(from, caller())), iszero(isApproved)), "0A") //from == msg.sender || isApproved
            }
            
            //相应去除授权
            iDID.uintData(address(this), from, to, isApproved ? approveAmt - amt : 0);
            iDID.uintData(address(this), from, address(0), balanceFrom - amt);
            _transfer(from, to, amt);
            return true;
        }
    }

    //方便转移和铸币
    function _transfer(address from, address to, uint amt) private {
        iDID.uintData(address(this), to, address(0), balanceOf(to) + amt);
        assembly {
            mstore(0x0, amt)
            log3(0x00, 0x20, 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, from, to)
        }

    }

    //切换暂停
    function toggleSuspend() external OnlyAccess {
        assembly {  //suspended = suspended == 0 ? 1 : 0;
            switch sload(0x1)
            case 1 {
                sstore(0x1, 0)
            }
            default {
                sstore(0x1, 1)
            }
        }
    }

    

    //铸币代币，只允许有访问权限的地址
    function mint(address addr, uint amt) public OnlyAccess {
        _mint(addr, amt);
    }

    function _mint(address addr, uint amt) private {
        assembly { //totalSupply += amt;
            sstore(0x4, add(amt, sload(0x4)))
        }
        _transfer(address(0), addr, amt); //调用标准函数
    }

    //烧毁代币，任何人都可以烧毁
    function burn(uint amt) external {
        assembly { //totalSupply -= amt;
            sstore(0x4, sub(sload(0x4), amt))
        }
        transferFrom(msg.sender, address(0), amt); //调用标准函数
    }

    //利用签名人来哈希信息
    function withdraw(address addr, uint amt, uint8 v, bytes32 r, bytes32 s) external {
        //确保账户不会被暂停、提款过早或签名错误
        require(iDID.uintData(address(0), addr, address(0)) == 0, "06");
        check(addr, v, r, s);
        _mint(addr, amt);
    }
}