// SPDX-License-Identifier: None
// solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Sign} from "Contracts/Util/Sign.sol";

// gas: 974705
contract ERC20 is Sign {

    event Transfer(address indexed from, address indexed to, uint amt);
    event Approval(address indexed from, address indexed to, uint amt);

    constructor(address sto, string memory name_, string memory symbol_) {
        assembly {
            // 设置string和string.length
            sstore(0x0, sto)
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
            // uintData(address(), addr, 0x0)
            mstore(0x80, 0x4c200b1000000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())
            mstore(0xa4, addr)
            mstore(0xc4, 0x2)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function allowance(address from, address to) public view returns(uint val) {
        assembly {
            // uintData(address(), from, to)
            mstore(0x80, 0x4c200b1000000000000000000000000000000000000000000000000000000000) 
            mstore(0x84, address())
            mstore(0xa4, from)
            mstore(0xc4, to)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    // gas: 61187/38302
    function approve(address to, uint amt) public returns(bool val) {
        assembly {
            // uintData(address(), caller(), to, amt)
            mstore(0x80, 0x9975842600000000000000000000000000000000000000000000000000000000) 
            mstore(0x84, address())
            mstore(0xa4, caller())
            mstore(0xc4, to)
            mstore(0xe4, amt)
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))
            val := 1

            // emit Approval(caller(), to, amt)
            mstore(0x0, amt)
            log3(0x0, 0x20, 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925, caller(), to)
        }
    }

    // gas: 77637/57972
    function transfer(address to, uint amt) external returns(bool val) {
        checkSuspend(msg.sender, to);
        assembly {
            // uintData(address(), caller(), 0x0)
            mstore(0x80, 0x4c200b1000000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())
            mstore(0xc4, 0x0)

            // balanceOf(msg.sender)
            mstore(0xa4, caller())
            mstore(0xc4, 0x2)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            let baf := mload(0x0)

            // balanceOf(to)
            mstore(0xa4, to)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            let bat := mload(0x0)

            //require(balanceOf(msg.sender) >= msg.sender)
            if gt(amt, baf) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0xf)
                mstore(0xC4, "Invalid balance")
                revert(0x80, 0x64)
            }

            // uintData(addres(), caller(), 0x0, amt)
            mstore(0x80, 0x9975842600000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())
            mstore(0xa4, caller())

            // -balanceOf(from)
            mstore(0xc4, 0x2)
            mstore(0xe4, sub(baf, amt))
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))

            // +balanceOf(to)
            mstore(0xa4, to)
            mstore(0xe4, add(bat, amt))
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))

            // emit Transfer(caller(), to, amt)
            mstore(0x0, amt)
            log3(0x0, 0x20, 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, caller(), to)

            // return true
            val := 1
        }
    }

    // gas: 85644/65979
    function transferFrom(address from, address to, uint amt) public returns(bool val) {
        checkSuspend(from, to);
        assembly {
            // uintData(address(), from, to)
            mstore(0x80, 0x4c200b1000000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())

            // balanceOf(to)
            mstore(0xa4, to)
            mstore(0xc4, 0x2)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            let bat := mload(0x0)

            // balanceOf(from)
            mstore(0xa4, from)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            let baf := mload(0x0)

            // allowance(from, msg.sender)
            mstore(0xa4, from)
            mstore(0xc4, caller())
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            let apa := mload(0x0)

            // require(amt <= balanceOf(from))
            if gt(amt, baf) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0xf)
                mstore(0xC4, "Invalid balance")
                revert(0x80, 0x64)
            }

            // require(amt <= allowance(from, msg.sender))
            if gt(amt, apa) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x10)
                mstore(0xC4, "Invalid approval")
                revert(0x80, 0x64)
            }

            // uintData(address(), from, to, amt)
            mstore(0x80, 0x9975842600000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())

            // -allowance(from, to)
            mstore(0xa4, from)
            mstore(0xc4, caller())
            mstore(0xe4, sub(apa, amt))
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))

            // -balanceOf(from)
            mstore(0xc4, 0x2)
            mstore(0xe4, sub(baf, amt))
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))

            // +balanceOf(to)
            mstore(0xa4, to)
            mstore(0xe4, add(amt, bat))
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))

            // emit Transfer(from, to, amt)
            mstore(0x0, amt)
            log3(0x0, 0x20, 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, from, to)

            //return true
            val := 1
        }
    }

    function withdraw(address to, uint amt, uint8 v, bytes32 r, bytes32 s) external {
        // 查拉黑和签名
        checkSuspend(msg.sender, to);
        check(to, v, r, s);
        assembly {
            // uintData(address(), 0x0, to)
            mstore(0x80, 0x4c200b1000000000000000000000000000000000000000000000000000000000)
            // balanceOf(to)
            mstore(0x84, address())
            mstore(0xa4, to)
            mstore(0xc4, 0x2)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))

            // uintData(address(), from, to, amt)
            mstore(0x80, 0x9975842600000000000000000000000000000000000000000000000000000000)
            // +balanceOf(to)
            mstore(0x84, address())
            mstore(0xa4, to)
            mstore(0xc4, 0x2)
            mstore(0xe4, add(amt, mload(0x0)))
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))

            // totalSupply += amt
            sstore(0x5, add(amt, sload(0x5)))

            // emit Transfer(0x0, to, amt)
            mstore(0x0, amt) 
            log3(0x0, 0x20, 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, 0x0, to)
        }
    }

    function burn(uint amt) external {
        assembly {
            // totalSupply -= amt;
            sstore(0x5, sub(sload(0x5), amt))
        }
        transferFrom(msg.sender, address(0), amt); //调用标准函数
    }

    /******************************************************************************/
    /******************************************************************************/
    /******************************************************************************/
    /******************************************************************************/
    /******************************************************************************/
    /*****************************纯测试，实时部署前得删*****************************/
    /******************************************************************************/
    /******************************************************************************/
    /******************************************************************************/
    /******************************************************************************/
    /******************************************************************************/
    function mint(address to, uint amt) external {
        assembly {
            // uintData(address(), to, 0x0)
            mstore(0x80, 0x4c200b1000000000000000000000000000000000000000000000000000000000)
            // balanceOf(to)
            mstore(0x84, address())
            mstore(0xa4, to)
            mstore(0xc4, 0x2)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))

            // uintData(address(), to, 0x0, amt)
            mstore(0x80, 0x9975842600000000000000000000000000000000000000000000000000000000)
            // +balanceOf(to)
            mstore(0x84, address())
            mstore(0xa4, to)
            mstore(0xc4, 0x2)
            mstore(0xe4, add(amt, mload(0x0)))
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))

            // totalSupply += amt
            sstore(0x5, add(amt, sload(0x5)))

            // emit Transfer(0x0, to, amt)
            mstore(0x0, amt) 
            log3(0x0, 0x20, 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, 0x0, to)
        }
    }
}