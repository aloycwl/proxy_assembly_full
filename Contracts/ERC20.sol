// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

import {Sign} from "Contracts/Util/Sign.sol";

// gas: 974705
contract ERC20 is Sign {

    bytes32 constant private STO = 0x79030946dd457157e4aa08fcb4907c422402e75f0f0ecb4f2089cb35021ff964;
    bytes32 constant private CNT = 0x5e423f2848a55862b54c89a4d1538a2d8aec99c1ee890237e17cdd6f0b5769d9;
    bytes32 constant private NA1 = 0xf81b3fd3135366259880acbe67fe529187df5bd875ef3a249ed4221ded1733a8;
    bytes32 constant private NA2 = 0xf2611493f75085dca50c1fd2ac8e34bc6d0eb7c274307efa54c50582314985bf;
    bytes32 constant private SB1 = 0x77f364795cb46b5690938fb39c14204236f4c9ec06ef0393ae0727afffac44e5;
    bytes32 constant private SB2 = 0x4bf7fd951d6e0483691bc47a65234a70074884918f0c2296cfe510ef5274b487;
    bytes32 constant private UIN = 0x4c200b1000000000000000000000000000000000000000000000000000000000;
    bytes32 constant private UID = 0x9975842600000000000000000000000000000000000000000000000000000000;
    bytes32 constant private APP = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;
    bytes32 constant private TTF = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    event Transfer(address indexed from, address indexed to, uint amt);
    event Approval(address indexed from, address indexed to, uint amt);

    constructor(address sto, string memory nam, string memory syb) {
        assembly {
            // 设置string和string.length
            sstore(STO, sto)
            sstore(NA1, mload(nam))
            sstore(NA2, mload(add(nam, 0x20)))
            sstore(SB1, mload(syb))
            sstore(SB2, mload(add(syb, 0x20)))
        }                                   
    }

    function decimals() external pure returns(uint val) {
        assembly {
            val := 0x12
        }
    }

    function totalSupply() external view returns(uint val) {
        assembly {
            val := sload(CNT)
        }
    }

    function name() external view returns(string memory val) {
        assembly {
            val := mload(0x40)
            mstore(0x40, add(val, 0x40))
            mstore(val, sload(NA1))
            mstore(add(val, 0x20), sload(NA2))
        }
    }

    function symbol() external view returns(string memory val) {
        assembly {
            val := mload(0x40)
            mstore(0x40, add(val, 0x40))
            mstore(val, sload(SB1))
            mstore(add(val, 0x20), sload(SB2))
        }
    }

    function balanceOf(address adr) public view returns(uint val) {
        assembly {
            // uintData(address(), addr, 0x0)
            mstore(0x80, UIN)
            mstore(0x84, address())
            mstore(0xa4, adr)
            mstore(0xc4, 0x02)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            val := mload(0x00)
        }
    }

    function allowance(address frm, address toa) public view returns(uint val) {
        assembly {
            // uintData(address(), from, to)
            mstore(0x80, UIN) 
            mstore(0x84, address())
            mstore(0xa4, frm)
            mstore(0xc4, toa)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            val := mload(0x00)
        }
    }

    // gas: 61187/38302
    function approve(address toa, uint amt) public returns(bool val) {
        assembly {
            // uintData(address(), caller(), to, amt)
            mstore(0x80, UID) 
            mstore(0x84, address())
            mstore(0xa4, caller())
            mstore(0xc4, toa)
            mstore(0xe4, amt)
            pop(call(gas(), sload(STO), 0x00, 0x80, 0x84, 0x00, 0x00))
            val := 0x01

            // emit Approval(caller(), to, amt)
            mstore(0x00, amt)
            log3(0x00, 0x20, APP, caller(), toa)
        }
    }

    // gas: 77637/57972
    function transfer(address toa, uint amt) external returns(bool val) {
        checkSuspend(msg.sender, toa);
        assembly {
            // uintData(address(), caller(), 0x0)
            mstore(0x80, UIN)
            mstore(0x84, address())
            mstore(0xc4, 0x00)

            // balanceOf(msg.sender)
            mstore(0xa4, caller())
            mstore(0xc4, 0x02)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            let baf := mload(0x00)

            // balanceOf(to)
            mstore(0xa4, toa)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            let bat := mload(0x00)

            //require(balanceOf(msg.sender) >= msg.sender)
            if gt(amt, baf) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x0f)
                mstore(0xC4, "Invalid balance")
                revert(0x80, 0x64)
            }

            // uintData(addres(), caller(), 0x0, amt)
            mstore(0x80, UID)
            mstore(0x84, address())
            mstore(0xa4, caller())

            // -balanceOf(from)
            mstore(0xc4, 0x02)
            mstore(0xe4, sub(baf, amt))
            pop(call(gas(), sload(STO), 0x00, 0x80, 0x84, 0x00, 0x00))

            // +balanceOf(to)
            mstore(0xa4, toa)
            mstore(0xe4, add(bat, amt))
            pop(call(gas(), sload(STO), 0x00, 0x80, 0x84, 0x00, 0x00))

            // emit Transfer(caller(), to, amt)
            mstore(0x00, amt)
            log3(0x00, 0x20, TTF, caller(), toa)

            // return true
            val := 0x01
        }
    }

    // gas: 85644/65979
    function transferFrom(address frm, address toa, uint amt) public returns(bool val) {
        checkSuspend(frm, toa);
        assembly {
            // uintData(address(), from, to)
            mstore(0x80, UIN)
            mstore(0x84, address())

            // balanceOf(to)
            mstore(0xa4, toa)
            mstore(0xc4, 0x02)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            let bat := mload(0x0)

            // balanceOf(from)
            mstore(0xa4, frm)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            let baf := mload(0x00)

            // allowance(from, msg.sender)
            mstore(0xa4, frm)
            mstore(0xc4, caller())
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x0, 0x20))
            let apa := mload(0x0)

            // require(amt <= balanceOf(from))
            if gt(amt, baf) {
                mstore(0x80, shl(0xe5, 0x461bcd)) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x0f)
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
            mstore(0x80, UID)
            mstore(0x84, address())

            // -allowance(from, to)
            mstore(0xa4, frm)
            mstore(0xc4, caller())
            mstore(0xe4, sub(apa, amt))
            pop(call(gas(), sload(STO), 0x00, 0x80, 0x84, 0x00, 0x00))

            // -balanceOf(from)
            mstore(0xc4, 0x02)
            mstore(0xe4, sub(baf, amt))
            pop(call(gas(), sload(STO), 0x00, 0x80, 0x84, 0x00, 0x00))

            // +balanceOf(to)
            mstore(0xa4, toa)
            mstore(0xe4, add(amt, bat))
            pop(call(gas(), sload(STO), 0x00, 0x80, 0x84, 0x00, 0x00))

            // emit Transfer(from, to, amt)
            mstore(0x00, amt)
            log3(0x00, 0x20, TTF, frm, toa)

            //return true
            val := 0x01
        }
    }

    function withdraw(address toa, uint amt, uint8 v, bytes32 r, bytes32 s) external {
        // 查拉黑和签名
        checkSuspend(msg.sender, toa);
        check(toa, v, r, s);
        assembly {
            // uintData(address(), 0x0, to)
            mstore(0x80, UIN)
            // balanceOf(to)
            mstore(0x84, address())
            mstore(0xa4, toa)
            mstore(0xc4, 0x02)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))

            // uintData(address(), from, to, amt)
            mstore(0x80, UID)
            // +balanceOf(to)
            mstore(0x84, address())
            mstore(0xa4, toa)
            mstore(0xc4, 0x02)
            mstore(0xe4, add(amt, mload(0x00)))
            pop(call(gas(), sload(STO), 0x00, 0x80, 0x84, 0x00, 0x00))

            // totalSupply += amt
            sstore(CNT, add(amt, sload(CNT)))

            // emit Transfer(0x0, to, amt)
            mstore(0x00, amt) 
            log3(0x00, 0x20, TTF, 0x00, toa)
        }
    }

    function burn(uint amt) external {
        assembly {
            // totalSupply -= amt;
            sstore(CNT, sub(sload(CNT), amt))
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
    function mint(address toa, uint amt) external {
        assembly {
            // uintData(address(), to, 0x0)
            mstore(0x80, UIN)
            // balanceOf(to)
            mstore(0x84, address())
            mstore(0xa4, toa)
            mstore(0xc4, 0x02)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))

            // uintData(address(), to, 0x0, amt)
            mstore(0x80, UID)
            // +balanceOf(to)
            mstore(0x84, address())
            mstore(0xa4, toa)
            mstore(0xc4, 0x02)
            mstore(0xe4, add(amt, mload(0x0)))
            pop(call(gas(), sload(STO), 0x0, 0x80, 0x84, 0x00, 0x00))

            // totalSupply += amt
            sstore(CNT, add(amt, sload(CNT)))

            // emit Transfer(0x0, to, amt)
            mstore(0x00, amt) 
            log3(0x00, 0x20, TTF, 0x00, toa)
        }
    }
}