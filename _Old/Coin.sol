// SPDX-License-Identifier: None
pragma solidity 0.8.18;
pragma abicoder v1;

//import {ItemMgmt} from "../Util/ItemMgmt.sol";

// gas: 974705
contract Coin {

    bytes32 constant internal STO = 0x79030946dd457157e4aa08fcb4907c422402e75f0f0ecb4f2089cb35021ff964;
    bytes32 constant internal CNT = 0x5e423f2848a55862b54c89a4d1538a2d8aec99c1ee890237e17cdd6f0b5769d9;
    bytes32 constant internal NAM = 0xbfc6089389a8677a26de8a30917b1b15a173691b166f48a89b49eec213ba87b0;
    bytes32 constant internal NA2 = 0xf2611493f75085dca50c1fd2ac8e34bc6d0eb7c274307efa54c50582314985bf;
    bytes32 constant internal SYM = 0x4d3015a52e62e7dc6887dd6869969b57532cf58982b1264ed2b19809b668f8e5;
    bytes32 constant internal SY2 = 0x96d8c7e9753d0c3dce20e0bd54a10932c96cf8457fe2ac7cebc4ca70af17a39a;
    bytes32 constant internal UIN = 0x4c200b1000000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal UID = 0x9975842600000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal ERR = 0x08c379a000000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal TTF = 0xa9059cbb00000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal ETF = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    bytes32 constant internal EAP = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    event Transfer(address indexed from, address indexed to, uint);
    event Approval(address indexed from, address indexed to, uint);

    constructor(address sto, string memory nam, string memory syb) {
        assembly {
            // 设置string和string.length
            sstore(STO, sto)
            sstore(NAM, mload(nam))
            sstore(NA2, mload(add(nam, 0x20)))
            sstore(SYM, mload(syb))
            sstore(SY2, mload(add(syb, 0x20)))
        }                                   
    }

    function decimals() external pure returns(uint) {
        assembly {
            mstore(0x00, 0x12)
            return(0x00, 0x20)
        }
    }

    function totalSupply() external view returns(uint) {
        assembly {
            mstore(0x00, sload(CNT))
            return(0x00, 0x20)
        }
    }

    function name() external view returns(string memory) {
        assembly {
            mstore(0x80, 0x20)
            mstore(0xa0, sload(NAM))
            mstore(0xc0, sload(NA2))
            return(0x80, 0x60)
        }
    }

    function symbol() external view returns(string memory) {
        assembly {
            mstore(0x80, 0x20)
            mstore(0xa0, sload(SYM))
            mstore(0xc0, sload(SY2))
            return(0x80, 0x60)
        }
    }

    function balanceOf(address adr) external view returns(uint) {
        assembly {
            // uintData(address(), addr, 0x0)
            mstore(0x80, UIN)
            mstore(0x84, address())
            mstore(0xa4, adr)
            mstore(0xc4, 0x02)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            return(0x00, 0x20)
        }
    }

    function allowance(address frm, address toa) external view returns(uint) {
        assembly {
            // uintData(address(), from, to)
            mstore(0x80, UIN) 
            mstore(0x84, address())
            mstore(0xa4, frm)
            mstore(0xc4, toa)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            return(0x00, 0x20)
        }
    }

    // gas: 61187/38302
    function approve(address toa, uint amt) external returns(bool) {
        assembly {
            // uintData(address(), caller(), to, amt)
            mstore(0x80, UID) 
            mstore(0x84, address())
            mstore(0xa4, caller())
            mstore(0xc4, toa)
            mstore(0xe4, amt)
            // emit Approval(caller(), to, amt)
            log3(0xe4, 0x20, EAP, caller(), toa)
            pop(call(gas(), sload(STO), 0x00, 0x80, 0x84, 0x00, 0x00))
            return(0x80, 0x20)
        }
    }

    // gas: 77637/57972
    function transfer(address toa, uint amt) external returns(bool) {
        //checkSuspend(msg.sender, toa);
        assembly {
            let sto := sload(STO)
            // uintData(address(), caller(), 0x0)
            mstore(0x80, UIN)
            mstore(0x84, address())
            mstore(0xc4, 0x00)

            // balanceOf(msg.sender)
            mstore(0xa4, caller())
            mstore(0xc4, 0x02)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))
            let baf := mload(0x00)

            // balanceOf(to)
            mstore(0xa4, toa)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))
            let bat := mload(0x00)

            //require(balanceOf(msg.sender) >= msg.sender)
            if gt(amt, baf) {
                mstore(0x80, ERR) 
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
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // +balanceOf(to)
            mstore(0xa4, toa)
            mstore(0xe4, add(bat, amt))
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // emit Transfer(caller(), to, amt)
            mstore(0x00, amt)
            log3(0x00, 0x20, ETF, caller(), toa)

            // return true
            return(0x00, 0x20)
        }
    }

    // gas: 85644/65979
    function transferFrom(address frm, address toa, uint amt) external returns(bool) {
        //checkSuspend(frm, toa);
        assembly {
            let sto := sload(STO)
            // uintData(address(), from, to)
            mstore(0x80, UIN)
            mstore(0x84, address())

            // balanceOf(to)
            mstore(0xa4, toa)
            mstore(0xc4, 0x02)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))
            let bat := mload(0x00)

            // balanceOf(from)
            mstore(0xa4, frm)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))
            let baf := mload(0x00)

            // allowance(from, msg.sender)
            mstore(0xa4, frm)
            mstore(0xc4, caller())
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x0, 0x20))
            let apa := mload(0x00)

            // require(amt <= balanceOf(from) || amt <= allowance(from, msg.sender))
            if and(gt(amt, baf), gt(amt, apa)) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x1b)
                mstore(0xC4, "Invalid balance or approval")
                revert(0x80, 0x64)
            }

            // uintData(address(), from, to, amt)
            mstore(0x80, UID)
            mstore(0x84, address())

            // -allowance(from, to)
            mstore(0xa4, frm)
            mstore(0xc4, caller())
            mstore(0xe4, sub(apa, amt))
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // -balanceOf(from)
            mstore(0xc4, 0x02)
            mstore(0xe4, sub(baf, amt))
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // +balanceOf(to)
            mstore(0xa4, toa)
            mstore(0xe4, add(amt, bat))
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // emit Transfer(from, to, amt)
            mstore(0x00, amt)
            log3(0x00, 0x20, ETF, frm, toa)

            //return true
            return(0x00, 0x20)
        }
    }

    function withdraw(uint amt/*, uint8 v, bytes32 r, bytes32 s*/) external {
        // 查拉黑和签名
        //checkSuspend(msg.sender, msg.sender);
        //check(amt, msg.sender, v, r, s);
        assembly {
            let sto := sload(STO)
            // address busd = uintData(0, 0, 2)
            mstore(0x80, UIN)
            mstore(0x84, 0x00)
            mstore(0xa4, 0x00)
            mstore(0xc4, 0x02)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))

            // transfer(msg.sender, amt)
            mstore(0x80, TTF)
            mstore(0x84, address())
            mstore(0xa4, caller())
            mstore(0xc4, 0x02)
            mstore(0xe4, add(amt, mload(0x00)))
            pop(call(gas(), mload(0x00), 0x00, 0x80, 0x84, 0x00, 0x00))

        }
    }

    function mint(address toa, uint amt/*, uint8 v, bytes32 r, bytes32 s*/) external {
        // 查拉黑和签名
        //checkSuspend(msg.sender, toa);
        //check(amt, toa, v, r, s);
        assembly {
            let sto := sload(STO)
            // balanceOf(to) = uintData(address(), 0x0, to)
            mstore(0x80, UIN)
            mstore(0x84, address())
            mstore(0xa4, toa)
            mstore(0xc4, 0x02)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))

            // balanceOf(to)++ uintData(address(), from, to, amt)
            mstore(0x80, UID)
            mstore(0x84, address())
            mstore(0xa4, toa)
            mstore(0xc4, 0x02)
            mstore(0xe4, add(amt, mload(0x00)))
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))

            // totalSupply += amt
            sstore(CNT, add(amt, sload(CNT)))

            // emit Transfer(0x0, to, amt)
            mstore(0x00, amt) 
            log3(0x00, 0x20, ETF, 0x00, toa)
        }
    }

    function burn(uint amt) external {
        assembly {
            // totalSupply -= amt;
            sstore(CNT, sub(sload(CNT), amt))
        }
        this.transferFrom(msg.sender, address(0), amt); //调用标准函数
    }

}