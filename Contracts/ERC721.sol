//SPDX-License-Identifier: None
//solhint-disable-next-line compiler-version
pragma solidity ^0.8.18;
pragma abicoder v1;

import {DID} from "Contracts/DID.sol";
import {Sign} from "Contracts/Util/Sign.sol";
import {Access} from "Contracts/Util/Access.sol";
import {DynamicPrice} from "Contracts/Util/DynamicPrice.sol";

interface IERC721 {
    event Transfer          (address indexed from, address indexed to, uint indexed id);
    event ApprovalForAll    (address indexed from, address indexed to, bool bol);
    event Approval          (address indexed from, address indexed to, uint indexed id);
    event MetadataUpdate    (uint id);
    
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
}

contract ERC721 is IERC721, IERC721Metadata, Access, Sign, DynamicPrice {
    
    DID iDID;
    uint   public  suspended;
    uint   public  count;

    //ERC20标准函数 
    constructor(address did, string memory name_, string memory symbol_) {
    /*constructor() {
        address did = 0xB57ee0797C3fc0205714a577c02F7205bB89dF30;
        string memory name_ = "";
        string memory symbol_ = "";*/
        assembly {
            sstore(0x0, did)
            sstore(0xa, caller())
            sstore(0x11, mload(name_))
            sstore(0x12, mload(add(name_, 0x20)))
            sstore(0x13, mload(symbol_))
            sstore(0x14, mload(add(symbol_, 0x20))) /*** TO RESLOT BACK ***/
        }
        iDID = DID(did);
    }

    function supportsInterface(bytes4 a) external pure returns(bool val) {
        assembly {
            val := or(eq(a, shl(0xe0, 0x80ac58cd)), eq(a, shl(0xe0, 0x5b5e139f))) 
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
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0x8c66f128)) // addressData(address,uint,uint)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x24), 0x0)
            mstore(add(ptr, 0x44), id)
            pop(staticcall(gas(), sload(0x0), ptr, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function getApproved(uint id) public view returns(address val) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0x8c66f128)) // addressData(address,uint,uint)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x24), 0x1)
            mstore(add(ptr, 0x44), id)
            pop(staticcall(gas(), sload(0x0), ptr, 0x64, 0x0, 0x20))
            val := mload(0x0)
        }
    }

    function isApprovedForAll(address from, address to) public view returns(bool val) {
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
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0xed3dae2b)) // addressData(address,uint256,uint256,address)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x24), 0x1)
            mstore(add(ptr, 0x44), id)
            mstore(add(ptr, 0x64), to)
            pop(call(gas(), sload(0x0), 0x0, ptr, 0x84, 0x0, 0x0))
            // emit Approval()
            log4(0x0, 0x0, 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925, oid, to, id)
        }
    }

    function setApprovalForAll(address to, bool bol) external {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0x99758426)) // uintData(address,address,address,uint256)
            mstore(add(ptr, 0x04), address())
            mstore(add(ptr, 0x24), caller())
            mstore(add(ptr, 0x44), to)
            mstore(add(ptr, 0x64), bol)
            pop(call(gas(), sload(0x0), 0x0, ptr, 0x84, 0x0, 0x0))
            // emit ApprovalForAll()
            mstore(0x0, bol)
            log3(0x0, 0x20, 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31, origin(), to)
        }
    }

    function balanceOf(address addr) public view returns (uint val) {
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

    function tokenURI(uint id) public view returns (string memory) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0xe0, 0x99eec064)) // stringData(address,uint)
            mstore(add(ptr, 0x4), address())
            mstore(add(ptr, 0x24), id)
            pop(staticcall(gas(), sload(0x0), ptr, 0x44, 0xa0, 0x80))
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
        unchecked {
            address ownerOfId = ownerOf(id);
            require(ownerOfId == from ||                                            //必须是所有者或
                    getApproved(id) == to ||                                        //已被授权或
                    isApprovedForAll(ownerOfId, from) ||                            //待全部出售或
                    this.access(msg.sender) > 0,                                    "0C");
            iDID.uintEnum(address(this), from, id, 1);                              //从所有者数组中删除
            iDID.addressData(address(this), 1, id, address(0));                     //重置授权
            iDID.uintData(address(this), from, to, 0);                              //重置操作员授权
            iDID.uintData(address(this), from, address(0), balanceOf(from) - 1);    //减少前任所有者的余额
            transfer(from, to, id);                                 
        }
    }

    //切换暂停
    function toggleSuspend() external OnlyAccess {
        suspended = suspended == 0 ? 1 : 0;
    }

    //获取地址拥有的所有代币的数组
    function tokensOwned(address addr) public view returns(uint[] memory) {
        return iDID.uintEnum(address(this), addr);
    }

    //通过将令牌转移到0x地址来销毁代币
    function burn(uint id) external {
        transferFrom(ownerOf(id), address(0), id);
    }

    //用于转移和铸币
    function transfer(address from, address to, uint id) private {
        unchecked {
            require(suspended == 0,                                                 "0D");
            require(iDID.uintData(address(0), from, address(0)) == 0 &&             //发件人不能被列入黑名单
                iDID.uintData(address(0), to, address(0)) == 0,                     "0E");
            if (to != address(0)) {
                iDID.uintEnum(address(this), to, id, 0);                           //添加到新的所有者数组
                iDID.uintData(address(this), to, address(0), balanceOf(to) + 1);    //添加当前所有者的余额                                                
            }
            iDID.addressData(address(this), 0, id, to);                             //更新NFT持有者
            assembly {
                log4(0x0, 0x0, 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef, from, to, id)
            }
        }
    }

    //铸造功能，需要先决条件，也用来升级或合并
    function assetify(uint l, address a, uint i, string calldata u, uint8 v, bytes32 r, bytes32 s) external payable {
        unchecked {
            pay(address(this), l, this.owner(), 0);                                 //若金额设定就支付
            check(a, v, r, s);                                                      //检查签名和更新指数
            iDID.stringData(address(this), i > 0 ? i : ++count, u);                 //更新或铸新
            if (i == 0) transfer(address(0), a, count);                             //铸币
            else                                                                    //更新元数据详细信息
            assembly {
                mstore(0x0, i)
                log1(0x0, 0x20, 0xf8e1a15aba9398e019f0b49df1a4fde98ee17ae345cb5f6b5e2c27f5033e8ce7)
            }
        }
    }

    //设置等级和价钱
    function setLevel(uint _list, address tokenAddr, uint price) external OnlyAccess {
        iDID.listData(address(this), address(this), _list, tokenAddr, price);
    }
    
    /*** TESTING ONLY ***/
    function assetify() public {
        iDID.stringData(address(this), ++count, "QmVegGmha4L4pLPQAj7V46kQVc8EoGnwwKvbKvHbevRYD2");
        transfer(address(0), msg.sender, count);
    }

}