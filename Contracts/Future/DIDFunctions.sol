// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

contract DIDFunctions {

    bytes32 constant private STO = 0x79030946dd457157e4aa08fcb4907c422402e75f0f0ecb4f2089cb35021ff964;
    bytes32 constant private STR = 0x99eec06400000000000000000000000000000000000000000000000000000000;
    bytes32 constant private STD = 0xc7070b5800000000000000000000000000000000000000000000000000000000;
    bytes32 constant private DID = 0x7148bc7200000000000000000000000000000000000000000000000000000000;

    // 用户名不能重复
    modifier OnlyUnique(string memory usn) {
        assembly {
            // address addr = stringData(address(), id)
            mstore(0x80, STR)
            mstore(0x84, caller())
            mstore(0xa4, 0x0)
            pop(staticcall(gas(), sload(STO), 0x80, 0x44, 0x0, 0x20))

            // require(addr = address(0))
            if gt(mload(0x0), 0x0) {
                mstore(0xA4, 0x10)
                mstore(0xC4, "Username existed")
                revert(0x80, 0x64)
            }
        }
        _;
    }

    constructor(address sto) {
        // iDID = DID(did);
        assembly {
            sstore(STO, sto)
        }
    }

    // 创造新用户
    function create(string memory usn, string memory nam, string memory bio) external OnlyUnique(usn) {
        assembly {
            // did[msg.sender] = usn 
            mstore(0x80, DID)
            mstore(0x84, mload(add(0x20, usn)))
            mstore(0xa4, caller())
            pop(call(gas(), sload(STO), 0x0, 0x80, 0x44, 0x00, 0x00))
        }
        update(0x00, usn);
        update(0x01, nam);
        update(0x02, bio);
    }

    // 改用户名
    function update(string memory aft) external OnlyUnique(aft) {
        assembly {
            // address bef = stringData(address(), id)
            mstore(0x80, STR)
            mstore(0x84, caller())
            mstore(0xa4, 0x00)
            pop(staticcall(gas(), sload(STO), 0x80, 0x44, 0x00, 0x20))

            // did[msg.sender] = address(0)
            mstore(0x80, DID)
            mstore(0x84, mload(add(0x20, mload(0x00))))
            mstore(0xa4, 0x00)
            pop(call(gas(), sload(STO), 0x0, 0x80, 0x44, 0x00, 0x00))

            // did[msg.sender] = aft 
            mstore(0x84, mload(add(0x20, aft)))
            mstore(0xa4, caller())
            pop(call(gas(), sload(STO), 0x00, 0x80, 0x44, 0x00, 0x00))

            // stringData[msg.sender][0] = usn
            mstore(0x80, STD)
            mstore(0x84, caller())
            mstore(0xa4, 0x00)
            mstore(0xc4, mload(aft))
            mstore(0xe4, mload(add(aft, 0x20)))
            mstore(0x0104, mload(add(aft, 0x40)))
            pop(call(gas(), sload(STO), 0x00, 0x80, 0xa4, 0x00, 0x00))
        }
    }

    // 更新其它资料
    function update(uint typ, string memory inf) public {
        assembly {
            // stringData[msg.sender][typ] = inf
            mstore(0x80, STD)
            mstore(0x84, caller())
            mstore(0xa4, typ)
            mstore(0xc4, mload(inf))
            mstore(0xe4, mload(add(inf, 0x20)))
            mstore(0x0104, mload(add(inf, 0x40)))
            pop(call(gas(), sload(STO), 0x00, 0x80, 0xa4, 0x00, 0x00))
        }
    }
}