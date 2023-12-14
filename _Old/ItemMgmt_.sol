// SPDX-License-Identifier: None
pragma solidity 0.8.18;

import {DynamicPrice} from "../Util/DynamicPrice.sol";

contract ItemMgmt is DynamicPrice {

    bytes32 constant internal STO = 0x79030946dd457157e4aa08fcb4907c422402e75f0f0ecb4f2089cb35021ff964;
    bytes32 constant internal CNT = 0x5e423f2848a55862b54c89a4d1538a2d8aec99c1ee890237e17cdd6f0b5769d9;
    bytes32 constant internal NAM = 0xbfc6089389a8677a26de8a30917b1b15a173691b166f48a89b49eec213ba87b0;
    bytes32 constant internal NA2 = 0xf2611493f75085dca50c1fd2ac8e34bc6d0eb7c274307efa54c50582314985bf;
    bytes32 constant internal SYM = 0x4d3015a52e62e7dc6887dd6869969b57532cf58982b1264ed2b19809b668f8e5;
    bytes32 constant internal SY2 = 0x96d8c7e9753d0c3dce20e0bd54a10932c96cf8457fe2ac7cebc4ca70af17a39a;
    bytes32 constant internal INF = 0x80ac58cd00000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal IN2 = 0x5b5e139f00000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal ADR = 0x8c66f12800000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal UIN = 0x4c200b1000000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal UID = 0x9975842600000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal CID = 0xd167a7b900000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal CI2 = 0x105ebda900000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal ENU = 0x650baf6000000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal PUS = 0x7cc553f400000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal POP = 0x4006163300000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal ERR = 0x08c379a000000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal TTF = 0xa9059cbb00000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal ETF = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    bytes32 constant internal EAP = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;
    bytes32 constant internal EAA = 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31;
    bytes32 constant internal EMD = 0xf8e1a15aba9398e019f0b49df1a4fde98ee17ae345cb5f6b5e2c27f5033e8ce7;
    bytes32 constant internal UI2 = 0x7fef772c00000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal UI1 = 0x84d6ad6100000000000000000000000000000000000000000000000000000000;

    // 新合约得换
    bytes32 constant internal ONO = 0x4c53ea35e789059b792e27d2fc83cc906ed9baceac2414c5e15a3de3bb205c6d;

    event Transfer(address indexed from, address indexed to, uint indexed id);
    event Approval(address indexed from, address indexed to, uint indexed id);
    event ApprovalForAll(address indexed from, address indexed to, bool);
    event MetadataUpdate(uint id);

    // 铸NFT
    function mint(uint lis, string[] memory uris, uint8 v, bytes32 r, bytes32 s) public {
        uint url = uris.length;
        for (uint i; i < url; i++) {
            string memory uri = uris[i];
            assembly {
                let sto := sload(STO)
                let ptr := mload(0x40)
                // count++
                let tid := add(sload(CNT), 0x01)
                sstore(CNT, tid)

                // tokensOwned()++ uintEnum(address(), to, id, 0x0)
                mstore(0x00, address())
                mstore(0x20, caller())
                mstore(ptr, PUS)
                mstore(add(ptr, 0x04), keccak256(0x00, 0x40))
                mstore(add(ptr, 0x24), tid)
                pop(call(gas(), sto, 0x00, ptr, 0x44, 0x00, 0x00))

                // balanceOf(to) = uintData(address(), msg.sender, 2)
                mstore(ptr, UIN)
                mstore(add(ptr, 0x04), address())
                mstore(add(ptr, 0x24), caller())
                mstore(add(ptr, 0x44), 0x02)
                pop(staticcall(gas(), sto, ptr, 0x64, 0x00, 0x20))
                // balanceOf(msg.sender)++ uintData(address(), msg.sender, 0, balanceOf(msg.sender))
                mstore(ptr, UID)
                mstore(add(ptr, 0x04), address())
                mstore(add(ptr, 0x24), caller())
                mstore(add(ptr, 0x44), 0x02)
                mstore(add(ptr, 0x64), add(0x01, mload(0x00)))
                pop(call(gas(), sto, 0x00, ptr, 0x84, 0x00, 0x00))

                // ownerOf[id] = to // uintData(bytes32, toa)
                mstore(0x00, ONO)
                mstore(0x20, tid)
                mstore(ptr, UI2)
                mstore(add(ptr, 0x04), keccak256(0x00, 0x40))
                mstore(add(ptr, 0x24), caller())
                pop(call(gas(), sto, 0x00, ptr, 0x44, 0x00, 0x00))   

                // tokenURI[l] = CIDData(address(), id, str1, str2)
                mstore(ptr, CID)
                mstore(add(ptr, 0x04), address())
                mstore(add(ptr, 0x24), tid)
                mstore(add(ptr, 0x44), mload(add(uri, 0x20)))
                mstore(add(ptr, 0x64), mload(add(uri, 0x40)))
                pop(call(gas(), sto, 0x00, ptr, 0x84, 0x00, 0x00))

                // emit Transfer()
                log4(0x00, 0x00, ETF, 0x00, caller(), tid)
            }
        }
        pay(address(this), lis, this.owner(), url, 0); // 若金额设定就支付
        checkSuspend(msg.sender, msg.sender); // 查有被拉黑不
        check(lis, msg.sender, v, r, s); // 查签名
    }

    /***************************************************************
    TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP 
    TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP 
    TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP 
    TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP 
    TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP
    ***************************************************************/ 
    function mintTEST() public {
            string memory uri = "QmNvWjdSxcXDzevFNYw46QkNvuTEod1FF8Le7GYLxWAavk";
            assembly {
                let sto := sload(STO)
                let ptr := mload(0x40)
                // count++
                let tid := add(sload(CNT), 0x01)
                sstore(CNT, tid)

                // tokensOwned()++ uintEnum(address(), to, id, 0x0)
                mstore(0x00, address())
                mstore(0x20, caller())
                mstore(ptr, PUS)
                mstore(add(ptr, 0x04), keccak256(0x00, 0x40))
                mstore(add(ptr, 0x24), tid)
                pop(call(gas(), sto, 0x00, ptr, 0x44, 0x00, 0x00))

                // balanceOf(to) = uintData(address(), msg.sender, 2)
                mstore(ptr, UIN)
                mstore(add(ptr, 0x04), address())
                mstore(add(ptr, 0x24), caller())
                mstore(add(ptr, 0x44), 0x02)
                pop(staticcall(gas(), sto, ptr, 0x64, 0x00, 0x20))
                // balanceOf(msg.sender)++ uintData(address(), msg.sender, 0, balanceOf(msg.sender))
                mstore(ptr, UID)
                mstore(add(ptr, 0x04), address())
                mstore(add(ptr, 0x24), caller())
                mstore(add(ptr, 0x44), 0x02)
                mstore(add(ptr, 0x64), add(0x01, mload(0x00)))
                pop(call(gas(), sto, 0x00, ptr, 0x84, 0x00, 0x00))

                // ownerOf[id] = to // uintData(bytes32, toa)
                mstore(0x00, ONO)
                mstore(0x20, tid)
                mstore(ptr, UI2)
                mstore(add(ptr, 0x04), keccak256(0x00, 0x40))
                mstore(add(ptr, 0x24), caller())
                pop(call(gas(), sto, 0x00, ptr, 0x44, 0x00, 0x00)) 

                // tokenURI[l] = CIDData(address(), id, str1, str2)
                mstore(ptr, CID)
                mstore(add(ptr, 0x04), address())
                mstore(add(ptr, 0x24), tid)
                mstore(add(ptr, 0x44), mload(add(uri, 0x20)))
                mstore(add(ptr, 0x64), mload(add(uri, 0x40)))
                pop(call(gas(), sto, 0x00, ptr, 0x84, 0x00, 0x00))

                // emit Transfer()
                log4(0x00, 0x00, ETF, 0x00, caller(), tid)
        }
    }

    // 提BUSD
    function withdraw(uint amt, uint8 v, bytes32 r, bytes32 s) external {
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
        
        // 查拉黑和签名
        checkSuspend(msg.sender, msg.sender);
        check(amt, msg.sender, v, r, s);
    }

    // 升级
    function upgrade(uint lis, uint tid, string memory uri, uint8 v, bytes32 r, bytes32 s) external payable {
        assembly {
            let sto := sload(STO)

            // ownerOf(tid) // uintData(bytes32)
            mstore(0x00, ONO)
            mstore(0x20, tid)
            mstore(0x80, UI1)
            mstore(0x84, keccak256(0x00, 0x40))
            pop(staticcall(gas(), sto, 0x80, 0x24, 0x00, 0x20))
            
            // require(ownerOf(tid) == msg.sender)
            if iszero(eq(mload(0x00), caller())) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x0c)
                mstore(0xC4, "Approval err")
                revert(0x80, 0x64)
            }

            // emit MetadataUpdate(i)
            mstore(0x00, tid)
            log1(0x00, 0x20, EMD)

            // tokenURI[l] = CIDData(address(), id, str1, str2)
            mstore(0xe0, CID)
            mstore(0xe4, address())
            mstore(0x0104, tid)
            mstore(0x0124, mload(add(uri, 0x20)))
            mstore(0x0144, mload(add(uri, 0x40)))
            pop(call(gas(), sto, 0x00, 0xe0, 0x84, 0x00, 0x00))
        }
        
        pay(address(this), lis, this.owner(), 1, 0); // 若金额设定就支付
        checkSuspend(msg.sender, msg.sender); // 查有被拉黑不
        check(lis, msg.sender, v, r, s); // 查签名
    }

    function check(uint amt, address adr, uint8 v, bytes32 r, bytes32 s) internal {

        bytes32 hsh;
        uint ind;

        assembly {
            // uintData(address(), addr, 0x1)
            mstore(0x80, UIN) 
            // 索取index
            mstore(0x84, address())
            mstore(0xa4, adr)
            mstore(0xc4, 0x01)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            ind := mload(0x00)
            // 拿哈希信息
            mstore(0x00, add(amt, add(adr, ind)))
            mstore(0x00, keccak256(0x00, 0x20))
            hsh := keccak256(0x00, 0x20)
        }

        address val = ecrecover(hsh, v, r, s);
        
        assembly {
            let sto := sload(STO)
            // addressData(0x0, 0x0, 0x1)；
            mstore(0x80, ADR) 
            // 索取signer
            mstore(0x84, 0x00)
            mstore(0xa4, 0x00)
            mstore(0xc4, 0x01)
            pop(staticcall(gas(), sto, 0x80, 0x64, 0x00, 0x20))
            // require(ecrecover == signer)
            if iszero(eq(val, mload(0x00))) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x07)
                mstore(0xC4, "Sig err")
                revert(0x80, 0x64)
            }
            // uintData(address(), addr, 0x1, ind++)
            mstore(0x80, UID)
            // 更新index
            mstore(0x84, address())
            mstore(0xa4, adr)
            mstore(0xc4, 0x01)
            mstore(0xe4, add(0x01, ind))
            pop(call(gas(), sto, 0x00, 0x80, 0x84, 0x00, 0x00))
        }
    }

    function checkSuspend(address adr, address ad2) internal view {
        assembly {
            // 环这3个地址
            mstore(0x80, address())
            mstore(0xa0, adr)
            mstore(0xc0, ad2)
            // uintData(address()/a/b, 0x0, 0x0)
            mstore(0xe0, UIN) 
            mstore(0x0104, 0x00)
            mstore(0x0124, 0x00)
            for { let i := 0x00 } lt(i, 0x03) { i := add(i, 0x01) } {
                // 地址是否被暂停
                mstore(0xe4, mload(add(mul(i, 0x20), 0x80)))
                pop(staticcall(gas(), sload(STO), 0xe0, 0x64, 0x00, 0x20))
                // require(x == 0)
                if gt(mload(0x00), 0x00) {
                    mstore(0x80, ERR) 
                    mstore(0x84, 0x20)
                    mstore(0xA4, 0x17)
                    mstore(0xC4, "Contract/user suspended")
                    revert(0x80, 0x64)
                }
            }
        }
    }

    // block.timestamp
    function getUint(address adr, uint uid) external view returns(uint) { // 0x2c7fb918
        assembly {
            // uintData(address(), addr, 0x0)
            mstore(0x80, UIN)
            mstore(0x84, address())
            mstore(0xa4, adr)
            mstore(0xc4, uid)
            pop(staticcall(gas(), sload(STO), 0x80, 0x64, 0x00, 0x20))
            return(0x00, 0x20)
        }
    }

}