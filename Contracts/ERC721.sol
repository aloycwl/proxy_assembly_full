// SPDX-License-Identifier: None
// solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {Sign} from "Contracts/Util/Sign.sol";
import {Access} from "Contracts/Util/Access.sol";
import {DynamicPrice} from "Contracts/Util/DynamicPrice.sol";

/*interface IERC721 {
    function balanceOf(address)                                        external view returns(uint);
    function ownerOf(uint)                                             external view returns(address);
    function safeTransferFrom(address, address, uint)                  external;
    function transferFrom(address, address, uint)                      external;
    function approve(address, uint)                                    external;
    function getApproved(uint)                                         external view returns(address);
    function setApprovalForAll(address, bool)                          external;
    function isApprovedForAll(address, address)                        external view returns(bool);
    function safeTransferFrom(address, address, uint, bytes calldata)  external;
}

interface IERC721Metadata {
    function name()                                                    external view returns(string memory);
    function symbol()                                                  external view returns(string memory);
    function tokenURI(uint)                                            external view returns(string memory);
}*/

contract ERC721 is /*IERC721, IERC721Metadata, */Access, Sign, DynamicPrice {
    event Transfer          (address indexed from, address indexed to, uint indexed id);
    event ApprovalForAll    (address indexed from, address indexed to, bool);
    event Approval          (address indexed from, address indexed to, uint indexed id);
    event MetadataUpdate    (uint id);

    //ERC20标准函数 
    constructor(address did, string memory name_, string memory symbol_) {
    /*constructor() {
        address did = 0xB57ee0797C3fc0205714a577c02F7205bB89dF30;
        string memory name_ = "";
        string memory symbol_ = "";*/
        assembly {
            sstore(0x0, did)
            sstore(0x2, mload(name_))
            sstore(0x3, mload(add(name_, 0x20)))
            sstore(0x4, mload(symbol_))
            sstore(0x5, mload(add(symbol_, 0x20)))
        }
    }

    function supportsInterface(bytes4 a) external pure returns(bool val) {
        assembly {
            val := or(eq(a, 0x80ac58cd00000000000000000000000000000000000000000000000000000000), 
                eq(a, 0x5b5e139f00000000000000000000000000000000000000000000000000000000)) 
        }
    }

    function count() external view returns(uint val) {
        assembly {
            val := sload(0x1)
        }
    }

    function name() external view returns(string memory val) {
        assembly {
            val := mload(0x40)
            mstore(0x40, add(val, 0x40))
            mstore(val, sload(0x2))
            mstore(add(val, 0x20), sload(0x3))
        }
    }

    function symbol() external view returns(string memory val) {
        assembly {
            val := mload(0x40)
            mstore(0x40, add(val, 0x40))
            mstore(val, sload(0x4))
            mstore(add(val, 0x20), sload(0x5))
        }
    }

    function ownerOf(uint id) public view returns(address val) { // 0x6352211e
        assembly {
            // addressData(address(), 0x0, id)
            mstore(0x80, 0x8c66f12800000000000000000000000000000000000000000000000000000000) 
            mstore(0x84, address())
            mstore(0xa4, 0x0)
            mstore(0xc4, id)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function getApproved(uint id) public view returns(address val) {
        assembly {
            // addressData(address(), 0x1, id)
            mstore(0x80, 0x8c66f12800000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())
            mstore(0xa4, 0x1)
            mstore(0xc4, id)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function isApprovedForAll(address from, address to) public view returns(bool val) { // 0xe985e9c5
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

    function approve(address to, uint id) external { // 0x095ea7b3
        address oid = ownerOf(id);
        bool bol = isApprovedForAll(oid, msg.sender);
        assembly {
            // require(msg.sender == ownerOf(id) || isApprovedForAll(ownerOf(id), msg.sender))
            if and(iszero(eq(caller(), oid)), iszero(bol)) {
                mstore(0x0, shl(0xe0, 0x5b4fb734))
                mstore(0x4, 0xb)
                revert(0x0, 0x24)
            }

            // addressData(address(), 0x1, id, to)
            mstore(0x80, 0xed3dae2b00000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())
            mstore(0xa4, 0x1)
            mstore(0xc4, id)
            mstore(0xe4, to)
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))

            // emit Approval()
            log4(0x0, 0x0, 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925, oid, to, id)
        }
    }

    function setApprovalForAll(address to, bool bol) external {
        assembly {
            // uintData(address(), caller(), to, bol)
            mstore(0x80, 0x9975842600000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())
            mstore(0xa4, caller())
            mstore(0xc4, to)
            mstore(0xe4, bol)
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))
            // emit ApprovalForAll()
            mstore(0x0, bol)
            log3(0x0, 0x20, 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31, origin(), to)
        }
    }

    function balanceOf(address addr) public view returns (uint val) {
        assembly {
            // uintData(address(), addr, 0x0)
            mstore(0x80, 0x4c200b1000000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())
            mstore(0xa4, addr)
            mstore(0xc4, 0x0)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function tokenURI(uint id) public view returns (string memory) {
        assembly {
            // stringData(address(), id)
            mstore(0x80, 0x99eec06400000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())
            mstore(0xa4, id)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x44, 0xa0, 0x80))

            // string.concat()
            mstore(0x80, 0x20)
            mstore(0xa0, add(mload(0xc0), 0x20))
            mstore(0xc0, "ipfs://")
            return(0x80, 0xa0)
        }
    }

    function safeTransferFrom(address from, address to, uint id) external {
        transferFrom(from, to, id); 
    }

    function safeTransferFrom(address from, address to, uint id, bytes memory) external {
        transferFrom(from, to, id); 
    }

    function transferFrom(address, address to, uint id) public { // 0x23b872dd
        (address oid, address app) = (ownerOf(id), getApproved(id));
        uint bal = balanceOf(oid);
        
        assembly {
            // require(所有者 || 被授权, "0c")
            if and(iszero(eq(app, to)), iszero(eq(oid, caller()))) {
                mstore(0x0, shl(0xe0, 0x5b4fb734))
                mstore(0x4, 0xc)
                revert(0x0, 0x24)
            }

            // uintEnum(address,address,uint256,uint256)
            mstore(0x80, 0x6795d52600000000000000000000000000000000000000000000000000000000)
            // --tokensOwned()
            mstore(0x84, address())
            mstore(0xa4, oid)
            mstore(0xc4, id)
            mstore(0xe4, 1)
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))

            // addressData(address,uint256,uint256,address)
            mstore(0x80, 0xed3dae2b00000000000000000000000000000000000000000000000000000000)
            // approval[id] = 0
            mstore(0x84, address())
            mstore(0xa4, 0x1)
            mstore(0xc4, id)
            mstore(0xe4, 0x0)
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))

            // uintData(address,address,address,uint256)
            mstore(0x80, 0x9975842600000000000000000000000000000000000000000000000000000000)
            // --balanceOf()
            mstore(0x84, address())
            mstore(0xa4, oid)
            mstore(0xc4, 0x0)
            mstore(0xe4, sub(bal, 0x1))
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))
        }
        mint(oid, to, id);
    }

    //获取地址拥有的所有代币的数组
    function tokensOwned(address addr) external view returns(uint[] memory val) {
        uint len;

        // 先拿数组长度
        assembly {
            // uintEnum(address(), addr)
            mstore(0x80, 0x82ff9d6f00000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())
            mstore(0xa4, addr)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x84, 0x0, 0x40))
            len := mload(0x20)
        }

        val = new uint[](len);

        // 再每格插入
        assembly {
            // uintEnum(address,address)
            mstore(0x80, 0x82ff9d6f00000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())
            mstore(0xa4, addr)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x44, 0xa0, mul(add(len, 0x2), 0x20)))
            
            for { let i := 0x0 } lt(i, add(len, 0x2)) { i := add(i, 0x1) } {
                mstore(add(val, mul(i, 0x20)), mload(add(0xa0, mul(add(i, 0x1), 0x20))))
            }
        }
    }

    //用于转移和铸币
    function mint(address from, address to, uint id) private {
        checkSuspend(from, to);
        uint bal = balanceOf(to);

        assembly {
            if gt(to, 0x0) {
                // uintEnum(address(), to, id, 0x0)
                mstore(0x80, 0x6795d52600000000000000000000000000000000000000000000000000000000)
                // ++tokensOwned()
                mstore(0x84, address())
                mstore(0xa4, to)
                mstore(0xc4, id)
                mstore(0xe4, 0x0)
                pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))

                // uintData(address,address,address,uint256)
                mstore(0x80, 0x9975842600000000000000000000000000000000000000000000000000000000)
                // ++balanceOf()
                mstore(0x84, address())
                mstore(0xa4, to)
                mstore(0xc4, 0x0)
                mstore(0xe4, add(0x1, bal))
                pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))
            }

            // addressData(address(), 0x0, id, to)
            mstore(0x80, 0xed3dae2b00000000000000000000000000000000000000000000000000000000)
            // 更新 ownerOf
            mstore(0x84, address())
            mstore(0xa4, 0x0)
            mstore(0xc4, id)
            mstore(0xe4, to)
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))
            
            // emit Transfer()
            log4(0x0, 0x0, 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, from, to, id)
        }
    }

    //铸造功能，需要先决条件，也用来升级或合并
    function assetify(uint l, address a, uint i, string memory u, uint8 v, bytes32 r, bytes32 s) external payable {
        pay(address(this), l, this.owner(), 0); //若金额设定就支付
        check(a, v, r, s);
        
        assembly {
            if iszero(i) {
                l := add(sload(0x1), 0x1)
                sstore(0x1, l)
            }
        }
        
        if (i == 0) mint(address(0), a, l); // 铸币

        assembly {
            if gt(i, 0) { // 更新元数据详细信息
                // count++
                mstore(0x0, i)
                log1(0x0, 0x20, 0xf8e1a15aba9398e019f0b49df1a4fde98ee17ae345cb5f6b5e2c27f5033e8ce7)
                l := i
            }         

            // stringData(address(), l, len, str1, str2)
            mstore(0x80, 0xc7070b5800000000000000000000000000000000000000000000000000000000)
            // 更新或铸新
            mstore(0x84, address())
            mstore(0xa4, l)
            mstore(0xc4, mload(u))
            mstore(0xe4, mload(add(u, 0x20)))
            mstore(0x104, mload(add(u, 0x40)))
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0xa4, 0x0, 0x0))
        }
    }

    //设置等级和价钱
    function setLevel(uint _list, address tokenAddr, uint price) external OnlyAccess {
        assembly {
            // listData(address(), address(), _list, tokenAddr, price)
            mstore(0x80, 0x41aa443600000000000000000000000000000000000000000000000000000000)
            mstore(0x84, address())
            mstore(0xa4, address())
            mstore(0xc4, _list)
            mstore(0xe4, tokenAddr)
            mstore(0x104, price)
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0xa4, 0x0, 0x0))
        }
    }
    
    /*** 纯测试，实时部署前得删 ||| 纯测试，实时部署前得删 ||| 纯测试，实时部署前得删 ***/
    /*** 纯测试，实时部署前得删 ||| 纯测试，实时部署前得删 ||| 纯测试，实时部署前得删 ***/
    /*** 纯测试，实时部署前得删 ||| 纯测试，实时部署前得删 ||| 纯测试，实时部署前得删 ***/
    /*** 纯测试，实时部署前得删 ||| 纯测试，实时部署前得删 ||| 纯测试，实时部署前得删 ***/
    /*** 纯测试，实时部署前得删 ||| 纯测试，实时部署前得删 ||| 纯测试，实时部署前得删 ***/
    function assetify() public {
        uint l;
        assembly {         
            // 更新或铸新
            l := add(sload(0x1), 0x1)
            mstore(0x80, 0xc7070b5800000000000000000000000000000000000000000000000000000000)

            // stringData(address(), l, len, str1, str2)
            mstore(0x84, address())
            mstore(0xa4, l)
            mstore(0xc4, 0x2c)
            mstore(0xe4, "QmVegGmha4L4pLPQAj7V46kQVc8EoGn")
            mstore(0x104, "wwKvbKvHbevRYD2")
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0xa4, 0x0, 0x0))

            // count++
            sstore(0x1, l)
        }
        mint(address(0), msg.sender, l);
    }
}