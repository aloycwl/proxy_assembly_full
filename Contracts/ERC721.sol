//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {DID} from "Contracts/DID.sol";
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
    event ApprovalForAll    (address indexed from, address indexed to, bool bol);
    event Approval          (address indexed from, address indexed to, uint indexed id);
    event MetadataUpdate    (uint id);
    
    DID iDID;

    //ERC20标准函数 
    constructor(address did, string memory name_, string memory symbol_) {
    /*constructor() {
        address did = 0xB57ee0797C3fc0205714a577c02F7205bB89dF30;
        string memory name_ = "";
        string memory symbol_ = "";*/
        assembly {
            sstore(0x0, did)
            sstore(0xa, caller())
            sstore(0xb, mload(name_))
            sstore(0xc, mload(add(name_, 0x20)))
            sstore(0xd, mload(symbol_))
            sstore(0xe, mload(add(symbol_, 0x20)))  
        }
        iDID = DID(did);
    }

    function supportsInterface(bytes4 a) external pure returns(bool val) {
        assembly {
            val := or(eq(a, shl(0xe0, 0x80ac58cd)), eq(a, shl(0xe0, 0x5b5e139f))) 
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
            mstore(val, sload(0x11))
            mstore(add(val, 0x20), sload(0x12))
        }
    }

    function symbol() external view returns(string memory val) {
        assembly {
            val := mload(0x40)
            mstore(0x40, add(val, 0x40))
            mstore(val, sload(0x13))
            mstore(add(val, 0x20), sload(0x14))
        }
    }

    function ownerOf(uint id) public view returns(address val) {
        assembly {
            mstore(0x80, shl(0xe0, 0x8c66f128)) // addressData(address,uint,uint)
            mstore(0x84, address())
            mstore(0xa4, 0x0)
            mstore(0xc4, id)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function getApproved(uint id) public view returns(address val) {
        assembly {
            mstore(0x80, shl(0xe0, 0x8c66f128)) // addressData(address,uint,uint)
            mstore(0x84, address())
            mstore(0xa4, 0x1)
            mstore(0xc4, id)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function isApprovedForAll(address from, address to) public view returns(bool val) {
        assembly {
            mstore(0x80, shl(0xe0, 0x4c200b10)) // uintData(address,address,address)
            mstore(0x84, address())
            mstore(0xa4, from)
            mstore(0xc4, to)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function approve(address to, uint id) external {
        address oid = ownerOf(id);
        bool bol = isApprovedForAll(oid, msg.sender);
        assembly {
            // require(msg.sender == ownerOf(id) || isApprovedForAll(ownerOf(id), msg.sender))
            if and(iszero(eq(caller(), oid)), iszero(bol)) {
                mstore(0x0, shl(0xe0, 0x5b4fb734))
                mstore(0x4, 0xb)
                revert(0x0, 0x24)
            }
            // 更新记录
            mstore(0x80, shl(0xe0, 0xed3dae2b)) // addressData(address,uint256,uint256,address)
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
            mstore(0x80, shl(0xe0, 0x99758426)) // uintData(address,address,address,uint256)
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
            mstore(0x80, shl(0xe0, 0x4c200b10)) // uintData(address,address,address)
            mstore(0x84, address())
            mstore(0xa4, addr)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function tokenURI(uint id) public view returns (string memory) {
        assembly {
            mstore(0x80, shl(0xe0, 0x99eec064)) // stringData(address,uint)
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

    function transferFrom(address from, address to, uint id) public {
        (address oid, address app) = (ownerOf(id), getApproved(id));
        unchecked {
            
            iDID.uintEnum(address(this), oid, id, 1);                              //从所有者数组中删除
            iDID.addressData(address(this), 1, id, address(0));                     //重置授权
            iDID.uintData(address(this), oid, to, 0);                              //重置操作员授权
            iDID.uintData(address(this), oid, address(0), balanceOf(from) - 1);    //减少前任所有者的余额
                                           
        }
        assembly {
            // require(所有者 || 被授权, "0c")
            if and(iszero(eq(app, to)), iszero(eq(oid, caller()))) {
                mstore(0x0, shl(0xe0, 0x5b4fb734))
                mstore(0x4, 0xc)
                revert(0x0, 0x24)
            }
            //从所有者数组中删除

        }
        mint(oid, to, id);
    }

    //获取地址拥有的所有代币的数组
    function tokensOwned(address addr) external view returns(uint[] memory val) {
        uint len;

        // 先拿数组长度
        assembly {
            mstore(0x80, shl(0xe0, 0x82ff9d6f)) // uintEnum(address,address)
            mstore(0x84, address())
            mstore(0xa4, addr)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x84, 0x0, 0x40))
            len := mload(0x20)
        }

        val = new uint[](len);

        // 再每格插入
        assembly {
            mstore(0x80, shl(0xe0, 0x82ff9d6f)) // uintEnum(address,address)
            mstore(0x84, address())
            mstore(0xa4, addr)
            pop(staticcall(gas(), sload(0x0), 0x80, 0x44, 0xa0, mul(add(len, 0x2), 0x20)))
            
            for { let i := 0x0 } lt(i, add(len, 0x2)) { i := add(i, 0x1) } {
                mstore(add(val, mul(i, 0x20)), mload(add(0xa0, mul(add(i, 0x1), 0x20))))
            }
        }
    }

    //用于转移和铸币
    function mint(address from, address to, uint id) private { // 0x668695c3
        checkSuspend(from, to);
        uint bal = balanceOf(to);

        assembly {
            if gt(to, 0x0) {
                // 加进 tokensOwned
                mstore(0x80, shl(0xe0, 0x6795d526)) // uintEnum(address,address)
                mstore(0x84, address())
                mstore(0xa4, to)
                mstore(0xc4, id)
                mstore(0xe4, 0x0)
                pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))
                // 添加 balanceOf
                mstore(0x80, shl(0xe0, 0x99758426)) // uintData(address,address,address,uint256)
                mstore(0x84, address())
                mstore(0xa4, to)
                mstore(0xc4, 0x0)
                mstore(0xe4, add(0x1, bal))
                pop(call(gas(), sload(0x0), 0x0, 0x80, 0x84, 0x0, 0x0))
            }
            // 更新 ownerOf
            mstore(0x80, shl(0xe0, 0xed3dae2b)) // addressData(address,uint256,uint256,address)
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
        
        if (i == 0) mint(address(0), a, l); //铸币

        assembly {
            if gt(i, 0) { //更新元数据详细信息
                mstore(0x0, i)
                log1(0x0, 0x20, 0xf8e1a15aba9398e019f0b49df1a4fde98ee17ae345cb5f6b5e2c27f5033e8ce7)
                l := i
            }             
            //更新或铸新
            mstore(0x80, shl(0xe0, 0xc7070b58)) // stringData(bytes32,bytes32,bytes32,bytes32,bytes32)
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
            mstore(0x80, shl(0xe0, 0x41aa4436)) // listData(address,address,uint256,address,uint256)
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
            //更新或铸新
            l := add(sload(0x1), 0x1)
            sstore(0x1, l)
            mstore(0x80, shl(0xe0, 0xc7070b58)) // stringData(bytes32,bytes32,bytes32,bytes32,bytes32)
            mstore(0x84, address())
            mstore(0xa4, l)
            mstore(0xc4, 0x2c)
            mstore(0xe4, "QmVegGmha4L4pLPQAj7V46kQVc8EoGn")
            mstore(0x104, "wwKvbKvHbevRYD2")
            pop(call(gas(), sload(0x0), 0x0, 0x80, 0xa4, 0x0, 0x0))
        }
        mint(address(0), msg.sender, l);
    }
}