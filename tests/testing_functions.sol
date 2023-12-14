// SPDX-License-Identifier: None
pragma solidity 0.8.23;
pragma abicoder v1;

contract test {
    function ownerOf(uint tid) external view returns(bytes32) {
        assembly {
            mstore(0x00, tid)
            mstore(0x00, keccak256(0x00, 0x20)) // 用0x00为储存
            return(0x00, 0x20)
        }
    }
}

    /***
    Attachment.sol
    ***/
    // function testMint() external { // 154013
    //     _mint("ifps://QmNvWjdSxcXDzevFNYw46QkNvuTEod1FF8Le7GYLxWAavk");
    //     setTop5(msg.sender);
    // }

    // function testMint(string[] calldata uris) external {
    //     uint len = uris.length;
    //     unchecked {
    //         for(uint i; i < len; ++i) _mint(uris[i]);
    //     }
    //     setTop5(msg.sender);
    // }

    /***
    Node.sol
    ***/
    // function resourceOut() external {
    //     _transfer(msg.sender, 0x0a);
    // }

    /***
    Top5.sol
    ***/
    // function TESTgetTop5() external view returns(address, uint, address, uint, address, uint, address, uint, address, uint) {
    //     assembly {
    //         mstore(0x80, sload(TP5))
    //         mstore(0xa0, sload(keccak256(0x80, 0x20)))
    //         mstore(0xc0, sload(add(TP5, 0x01)))
    //         mstore(0xe0, sload(keccak256(0xc0, 0x20)))
    //         mstore(0x0100, sload(add(TP5, 0x02)))
    //         mstore(0x0120, sload(keccak256(0x0100, 0x20)))
    //         mstore(0x0140, sload(add(TP5, 0x03)))
    //         mstore(0x0160, sload(keccak256(0x0140, 0x20)))
    //         mstore(0x0180, sload(add(TP5, 0x04)))
    //         mstore(0x01a0, sload(keccak256(0x0180, 0x20)))
    //         return(0x80, 0x140)
    //     }
    // }

    // function TESTsetTop5() external {
    //     assembly {
    //         mstore(0x00, 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4)
    //         sstore(TP5, mload(0x00))
    //         sstore(keccak256(0x00, 0x20), 0x05)
    //         mstore(0x00, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)
    //         sstore(add(TP5, 0x01), mload(0x00))
    //         sstore(keccak256(0x00, 0x20), 0x06)
    //         mstore(0x00, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db)
    //         sstore(add(TP5, 0x02), mload(0x00))
    //         sstore(keccak256(0x00, 0x20), 0x07)
    //         mstore(0x00, 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB)
    //         sstore(add(TP5, 0x03), mload(0x00))
    //         sstore(keccak256(0x00, 0x20), 0x08)
    //         mstore(0x00, 0x617F2E2fD72FD9D5503197092aC168c91465E7f2)
    //         sstore(add(TP5, 0x04), mload(0x00))
    //         sstore(keccak256(0x00, 0x20), 0x09)
    //     }
    // }

    // function TESTaddBal() external {
    //     assembly {
    //         mstore(0x00, caller())
    //         let ptr := keccak256(0x00, 0x20)
    //         sstore(ptr, add(sload(ptr), 0x01))
    //     }
    //     setTop5(msg.sender);
    // }