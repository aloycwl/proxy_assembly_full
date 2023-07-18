//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Access} from "Contracts/Util/Access.sol";
import {Sign} from "Contracts/Util/Sign.sol";

//代币合约
contract ERC20 is Access, Sign {

    event Transfer(address indexed from, address indexed to, uint amt);
    event Approval(address indexed from, address indexed to, uint amt);

    //ERC20标准函数 
    constructor(address did, string memory name_, string memory symbol_) {
        assembly {
            sstore(0x0, did)
            sstore(0x1, mload(name_))
            sstore(0x2, mload(add(name_, 0x20)))
            sstore(0x3, mload(symbol_))
            sstore(0x4, mload(add(symbol_, 0x20)))
        }                                   
    }

    function decimals() external pure returns(uint val) {
        assembly {
            val := 0x12
        }
    }

    function totalSupply() external view returns(uint val) {
        assembly {
            val := sload(0x5)
        }
    }

    function name() external view returns(string memory val) {
        assembly {
            val := mload(0x40)
            mstore(0x40, add(val, 0x40))
            mstore(val, sload(0x1))
            mstore(add(val, 0x20), sload(0x2))
        }
    }

    function symbol() external view returns(string memory val) {
        assembly {
            val := mload(0x40)
            mstore(0x40, add(val, 0x40))
            mstore(val, sload(0x3))
            mstore(add(val, 0x20), sload(0x4))
        }
    }

    function balanceOf(address addr) public view returns(uint val) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0x4c200b10)) // uintData(address,address,address)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x24), addr)
            mstore(add(ptr, 0x44), 0x0)
            pop(staticcall(gas(), sload(0x0), ptr, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function allowance(address from, address to) public view returns(uint val) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0x4c200b10)) // uintData(address,address,address)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x24), from)
            mstore(add(ptr, 0x44), to)
            pop(staticcall(gas(), sload(0x0), ptr, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function approve(address to, uint amt) public returns(bool val) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0x99758426)) // uintData(address,address,address,uint256)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x24), caller())
            mstore(add(ptr, 0x44), to)
            mstore(add(ptr, 0x64), amt)
            pop(call(gas(), sload(0x0), 0x0, ptr, 0x84, 0x0, 0x0))
            val := 1
            // emit Approval(address,address,uint256)
            mstore(0x0, amt)
            log3(0x0, 0x20, 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925, caller(), to)
        }
    }

    function transfer(address to, uint amt) external returns(bool) {
        return transferFrom(msg.sender, to, amt);
    }

    function transferFrom(address from, address to, uint amt) public returns(bool val) {
        (uint approveAmt, uint balanceFrom) = (allowance(from, to), balanceOf(from));
        assembly {
            let isApproved := iszero(gt(amt, approveAmt))
            // require(balanceFrom >= amt && (from == msg.sender || isApproved), "0x9 & 0xa")
            function x(con, cod) {
                if gt(con, 0x0) {
                    mstore(0x0, shl(0xe0, 0x5b4fb734))
                    mstore(0x4, cod)
                    revert(0x0, 0x24)
                }
            }
            x(gt(amt, balanceFrom), 0x9)
            x(and(iszero(eq(from, caller())), iszero(isApproved)), 0xa)
            // -balanceOf(from)
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0x99758426)) // uintData(address,address,address,uint256)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x24), from)
            mstore(add(ptr, 0x44), 0x0)
            mstore(add(ptr, 0x64), sub(balanceFrom, amt))
            pop(call(gas(), sload(0x0), 0x0, ptr, 0x84, 0x0, 0x0))
            // 扣除授权数额
            if gt(isApproved, 0) {
                approveAmt := sub(approveAmt, amt)
            }
            if iszero(isApproved) {
                approveAmt := 0x0
            }
            mstore(add(ptr, 0x44), to)
            mstore(add(ptr, 0x64), approveAmt)
            pop(call(gas(), sload(0x0), 0x0, ptr, 0x84, 0x0, 0x0))
            //return true
            val := 1
        }
        _transfer(from, to, amt);
    }

    //方便转移和铸币
    function _transfer(address from, address to, uint amt) private {
        assembly {
            // 查合约暂停
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0x4c200b10)) // uintData(address,address,address)
            mstore(add(ptr, 0x04), 0x0)
            mstore(add(ptr, 0x24), address())
            mstore(add(ptr, 0x44), 0x0)
            pop(staticcall(gas(), sload(0x0), ptr, 0x64, 0x0, 0x20))
            let u1 := mload(0x0)
            // 查用户暂停
            mstore(add(ptr, 0x24), from)
            pop(staticcall(gas(), sload(0x0), ptr, 0x64, 0x0, 0x20))
            let u2 := mload(0x0)
            // 查收信人暂停
            mstore(add(ptr, 0x24), to)
            pop(staticcall(gas(), sload(0x0), ptr, 0x64, 0x0, 0x20))
            let u3 := mload(0x0)
            // require(u1 == 0 && u2 == 0 && u3 == 0, "0x7")
            if gt(or(or(gt(u1, 0x0), gt(u2, 0x0)), gt(u3, 0x0)), 0x0) {
                mstore(0x0, shl(0xe0, 0x5b4fb734))
                mstore(0x4, 0x7)
                revert(0x0, 0x24)
            }
            // balanceOf(to)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x24), to)
            pop(staticcall(gas(), sload(0x0), ptr, 0x64, 0x0, 0x20))
            amt := add(mload(0x0), amt)
            // +balanceOf(to)
            mstore(ptr, shl(0xe0, 0x99758426)) // uintData(address,address,address,uint256)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x64), amt)
            pop(call(gas(), sload(0x0), 0x0, ptr, 0x84, 0x0, 0x0)) 
            // emit Transfer(address,address,uint256)
            mstore(0x0, amt)
            log3(0x0, 0x20, 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, from, to)
        }
    }

    //铸币代币，只允许有访问权限的地址
    function mint(address addr, uint amt) public OnlyAccess {
        _mint(addr, amt);
    }

    function _mint(address addr, uint amt) private {
        assembly { //totalSupply += amt;
            sstore(0x5, add(amt, sload(0x5)))
        }
        _transfer(address(0), addr, amt); //调用标准函数
    }

    //烧毁代币，任何人都可以烧毁
    function burn(uint amt) external {
        assembly { //totalSupply -= amt;
            sstore(0x5, sub(sload(0x5), amt))
        }
        transferFrom(msg.sender, address(0), amt); //调用标准函数
    }

    //利用签名人来哈希信息
    function withdraw(address addr, uint amt, uint8 v, bytes32 r, bytes32 s) external {
        check(addr, v, r, s);
        _mint(addr, amt);
    }
}