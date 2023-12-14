// SPDX-License-Identifier: None
pragma solidity 0.8.23;
pragma abicoder v1;

import {Check} from "../Util/Check.sol";

contract Node is Check {

    event Transfer(address indexed from, address indexed to, uint);

    modifier onlyTop5() {
        assembly {
            mstore(0x00, TP5) // Top5(TPS).isTop5(msg.sender)
            mstore(0x04, origin())
            pop(staticcall(gas(), sload(TP5), 0x00, 0x24, 0x80, 0x20))
            if iszero(mload(0x80)) {
                mstore(0x80, ERR)
                mstore(0xa0, STR)
                mstore(0xc0, ER1)
                revert(0x80, 0x64)
            }
        }
        _;
    }
    
    function games(address adr) external view returns(bool) {
        assembly {
            mstore(0x00, sload(shl(0x05, adr)))
            return(0x00, 0x20)
        }
    }

    function checkVoting(uint ind) external view returns(uint, address, bytes32[5] memory, address) { 
        assembly {
            mstore(0x00, ind)
            let ptr := keccak256(0x00, 0x20)
            for { let i } lt(i, 0x08) { i := add(i, 0x01) } {
                mstore(add(0x80, mul(i, 0x20)), sload(add(ptr, i)))
            }
            return(0x80, 0x0100)
        }
    }

    function count() external view returns(uint) {
        assembly {
            mstore(0x00, sload(INF))
            return(0x00, 0x20)
        }
    }

    function resourceOut(uint amt, uint8 v, bytes32 r, bytes32 s) external {
        _transfer(msg.sender, amt);
        isVRS(amt, v, r, s);
    }

    function resourceIn(address adr, uint amt) external {
        assembly { 
            if iszero(sload(shl(0x05, adr))) { // require(games[adr], "not supported");
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER1)
                revert(0x80, 0x64)
            }

            mstore(0x00, amt) // emit Transfer(adr, ad2, amt)
            log3(0x00, 0x20, ETF, caller(), adr) 

            mstore(0x80, TFM)  // require(transferForm(origin(), to, fee))
            mstore(0x84, caller()) 
            mstore(0xa4, address())
            mstore(0xc4, amt)
            if iszero(call(gas(), sload(TTF), 0x00, 0x80, 0x64, 0x00, 0x00)) {
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER2)
                revert(0x80, 0x64)
            }
        }
    }

    function createVote(address adr, uint stt) external returns(uint cnt) { // stt: 1-加游, 2-删游, 3-提币
        assembly {
            cnt := add(sload(INF), 0x01)
            sstore(INF, cnt) // ++count;

            mstore(0x00, cnt)
            let ptr := keccak256(0x00, 0x20)
            sstore(ptr, stt)
            sstore(add(ptr, 0x01), adr)
            sstore(add(ptr, 0x07), origin())
        }
    }

    function cancelVote(uint stt) external {
        assembly {
            mstore(0x00, stt)
            let ptr := keccak256(0x00, 0x20)
            if iszero(eq(sload(add(ptr, 0x07)), origin())) { // require(vote[stt].creator == msg.sender)
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER1)
                revert(0x80, 0x64)
            }
            sstore(ptr, 0x00) // vote[stt].status = 0
            sstore(add(ptr, 0x07), 0x00) // vote[stt].creator = address(0)
        }
    }

    function vote(uint ind, bool vot) external onlyTop5 {
        address toa;
        uint amt;

        assembly {
            mstore(0x00, ind)
            let ptr := keccak256(0x00, 0x20)
            let up
            let down

            for { let i := add(ptr, 0x02) } lt(i, add(ptr, 0x07)) { i := add(i, 0x01) } {
                let sli := sload(i)
                if iszero(sli) { // 空位
                    ind := i
                    break
                }
                if gt(sli, 0x00) {
                    switch gt(sli, STR) 
                    case 1 { 
                        up := add(up, 0x01)  // ++up;
                        mstore(0x00, sli) // 0x0100... > 0x0000...
                        mstore8(0x00, 0x00)
                        sli := mload(0x00)
                    }
                    default { down := add(down, 0x01) } // ++down;
                }
                if eq(sli, caller()) { // 已投
                    ind := 0x00
                    break
                }
            }

            let sta := sload(ptr)
            if or(iszero(sta), iszero(ind)) { // require(vo.status != 0 && vo.voters[i] != msg.sender);
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER1)
                revert(0x80, 0x64)
            }

            mstore(0x00, caller())
            mstore8(0x00, vot)
            sstore(ind, mload(0x00)) // vo.voters.push(msg.sender);

            if or(eq(up, 0x02), eq(down, 0x02)) { // 投票完毕
                switch vot // 最后一票
                case 0x0 { down := add(down, 0x01) } // ++down;
                default { up := add(up, 0x01) } // ++up;
                if gt(up, 0x02) { 
                    switch gt(sta, 0x02)
                    case 1 { // 提币
                        toa := sload(add(ptr, 0x01))
                        amt := sta
                    }
                    default {  // 加/减游戏
                        sstore(shl(0x05, sload(add(ptr, 0x01))), mod(sta, 0x02))
                    }
                }
                sstore(ptr, 0x00) // vo.status = 0;
            }
        }

        if(amt > 0x00) _transfer(toa, amt);
    }

    function _transfer(address toa, uint amt) private {
        assembly {
            mstore(0x80, TTF)  // transfer(toa, amt)
            mstore(0x84, toa)
            mstore(0xa4, amt)
            if iszero(call(gas(), sload(TTF), 0x00, 0x80, 0x44, 0x00, 0x00)) {
                mstore(0x80, ERR) 
                mstore(0xa0, STR)
                mstore(0xc0, ER5)
                revert(0x80, 0x64)
            }
        }
    }

}