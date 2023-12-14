// SPDX-License-Identifier: None
pragma solidity 0.8.18;

import {DynamicPrice} from "../Util/DynamicPrice.sol";

contract ItemMgmt is DynamicPrice {

    bytes32 constant internal CNT = 0x5e423f2848a55862b54c89a4d1538a2d8aec99c1ee890237e17cdd6f0b5769d9;
    bytes32 constant internal NAM = 0xbfc6089389a8677a26de8a30917b1b15a173691b166f48a89b49eec213ba87b0;
    bytes32 constant internal NA2 = 0xf2611493f75085dca50c1fd2ac8e34bc6d0eb7c274307efa54c50582314985bf;
    bytes32 constant internal SYM = 0x4d3015a52e62e7dc6887dd6869969b57532cf58982b1264ed2b19809b668f8e5;
    bytes32 constant internal SY2 = 0x96d8c7e9753d0c3dce20e0bd54a10932c96cf8457fe2ac7cebc4ca70af17a39a;
    bytes32 constant internal INF = 0x80ac58cd00000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal IN2 = 0x5b5e139f00000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal TTF = 0xa9059cbb00000000000000000000000000000000000000000000000000000000;
    bytes32 constant internal ETF = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    bytes32 constant internal EAP = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;
    bytes32 constant internal EAA = 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31;
    bytes32 constant internal EMD = 0xf8e1a15aba9398e019f0b49df1a4fde98ee17ae345cb5f6b5e2c27f5033e8ce7;
    bytes32 constant internal TKO = 0x2b5cce509006327e7e57324c5318a79e6592448a14348d903d7e82e569af36cb;
    bytes32 constant internal APP = 0x240b7221e3cefc50f1f977e26ab6b0c0225e46cac4fa22bc3cd360265249f2dd;
    bytes32 constant internal ER3 = 0x73757370656e6465640000000000000000000000000000000000000000000000;
    bytes32 constant internal ER4 = 0x7369672065727200000000000000000000000000000000000000000000000000;
    bytes32 constant internal USD = 0xdfc7054f7e556cdc2d4cbcede032e6e55d7f7f2f1e0d9cc5c2429cc32806b2ba;
    bytes32 constant internal IND = 0x015739b0ed70d62a76f5fd8ef1d120e11252c6a0364e3cca4ff6bb4dce79e702;
    bytes32 constant internal SIG = 0xcbfe4baa920060fc34aa65135b74b83fa81df36f6e21d90c8301c8810d2c89d9;
    bytes32 constant internal FEE = 0x607744c37698f0ad2c7e8b300d57eaef2f987ccbb958ce7cd316a2c3e663f9ec;

    event Transfer(address indexed from, address indexed to, uint indexed id);
    event Approval(address indexed from, address indexed to, uint indexed id);
    event ApprovalForAll(address indexed from, address indexed to, bool);
    event MetadataUpdate(uint id);

    // 铸NFT
    function mint(uint lis, string[] memory uris, uint8 v, bytes32 r, bytes32 s) public payable {
        uint url = uris.length;
        uint fee;
        for (uint i; i < url; i++) {
            string memory uri = uris[i];
            assembly {
                let tid := add(sload(CNT), 0x01) // count++
                sstore(CNT, tid)

                mstore(0x00, caller()) // balanceOf(msg.sender)++
                let tmp := keccak256(0x00, 0x20)
                sstore(tmp, add(sload(tmp), 0x01))

                sstore(tid, caller()) // ownerOf[tid] = msg.sender

                mstore(0x00, tid) // tokenURI[tid] = uri
                tmp := keccak256(0x00, 0x20)
                sstore(tmp, mload(add(uri, 0x20)))
                sstore(add(tmp, 0x01), mload(add(uri, 0x40)))

                log4(0x00, 0x00, ETF, 0x00, caller(), tid) // emit Transfer()
            }
        }
        assembly {
            fee := sload(FEE)
        }
        pay(lis, this.owner(), url, fee); // 若金额设定就支付
        checkSuspend(msg.sender, msg.sender); // 查有被拉黑不
        check(lis, msg.sender, v, r, s); // 查签名
    }

    /***************************************************************
    TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP
    ***************************************************************/ 
    function mintTEST() public {
            string memory uri = "ipfs://QmNvWjdSxcXDzevFNYw46QkNvuTEod1FF8Le7GYLxWAavk";
            uint fee;
            assembly {
                fee := sload(FEE)

                let tid := add(sload(CNT), 0x01) // count++
                sstore(CNT, tid)

                mstore(0x00, caller()) // balanceOf(msg.sender)++
                let tmp := keccak256(0x00, 0x20)
                sstore(tmp, add(sload(tmp), 0x01))

                sstore(tid, caller()) // ownerOf[tid] = msg.sender

                mstore(0x00, tid) // tokenURI[tid] = uri
                tmp := keccak256(0x00, 0x20)
                sstore(tmp, mload(add(uri, 0x20)))
                sstore(add(tmp, 0x01), mload(add(uri, 0x40)))

                log4(0x00, 0x00, ETF, 0x00, caller(), tid) // emit Transfer()
        }
        checkSuspend(msg.sender, msg.sender); // 查有被拉黑不
        pay(0, this.owner(), 1, fee); // 若金额设定就支付
    }

    // 提BUSD
    function withdraw(uint amt, uint8 v, bytes32 r, bytes32 s) external {
        assembly {
            mstore(0x80, TTF) // ERC20(amt).transfer(msg.sender, amt)
            mstore(0x84, caller())
            mstore(0xc4, amt)
            pop(call(gas(), sload(USD), 0x00, 0x80, 0x44, 0x00, 0x00))
        }
        checkSuspend(msg.sender, msg.sender);
        check(amt, msg.sender, v, r, s);
    }

    // 升级
    function upgrade(uint lis, uint tid, string memory uri, uint8 v, bytes32 r, bytes32 s) external payable {
        uint fee;
        assembly {
            mstore(0x00, sload(tid)) // ownerOf(tid)
            
            if iszero(eq(mload(0x00), caller())) { // require(ownerOf(tid) == msg.sender)
                mstore(0x80, ERR) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x0b)
                mstore(0xC4, ER2)
                revert(0x80, 0x64)
            }

            mstore(0x00, tid) // emit MetadataUpdate(tid)
            log1(0x00, 0x20, EMD)

            mstore(0x00, tid) // tokenURI[tid] = uri
            let tmp := keccak256(0x00, 0x20)
            sstore(tmp, mload(add(uri, 0x20)))
            sstore(add(tmp, 0x01), mload(add(uri, 0x40)))

            fee := sload(FEE)
        }
        pay(lis, this.owner(), 1, fee); // 若金额设定就支付
        checkSuspend(msg.sender, msg.sender); // 查有被拉黑不
        check(lis, msg.sender, v, r, s); // 查签名
    }

    function check(uint amt, address adr, uint8 v, bytes32 r, bytes32 s) internal {

        bytes32 hsh;

        assembly {
            mstore(0x00, IND)
            mstore(0x20, caller())
            let ptr := keccak256(0x00, 0x40)
            let ind := sload(ptr)
            mstore(0x00, add(amt, add(adr, ind))) // 拿哈希信息
            mstore(0x00, keccak256(0x00, 0x20))
            hsh := keccak256(0x00, 0x20)
            sstore(ptr, add(ind, 0x01))
        }

        address val = ecrecover(hsh, v, r, s);
        
        assembly {
            if iszero(eq(val, sload(SIG))) { // require(val == signer)
                mstore(0x80, ERR) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x07)
                mstore(0xC4, ER4)
                revert(0x80, 0x64)
            }
        }
    }

    function checkSuspend(address adr, address ad2) internal view {
        assembly {
            // require(!suspended[address(this)] && !suspended[adr] && !suspended[ad2]);
            if or(or(gt(sload(address()), 0x00), gt(sload(adr), 0x00)), gt(sload(ad2), 0x00)) {
                mstore(0x80, ERR) 
                mstore(0x84, 0x20)
                mstore(0xA4, 0x09)
                mstore(0xC4, ER3)
                revert(0x80, 0x64)
            }
        }
    }

}