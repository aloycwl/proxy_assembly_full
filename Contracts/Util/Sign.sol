//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

//import {LibUint} from "Contracts/Util/LibUint.sol";
import {DID}     from "Contracts/DID.sol";

contract Sign is DID {

    //using LibUint for uint;

    DID internal iDID;

    constructor(address did) {

        iDID = DID(did);

    }

    function check(address addr, uint8 v, bytes32 r, bytes32 s) internal {

        //间隔条件
        require(iDID.uintData(address(this), addr, address(1)) + 
            iDID.uintData(address(this), addr, address(2)) < block.timestamp, "02");
        
        //签名条件
        require(          
            ecrecover(
                keccak256(abi.encodePacked(keccak256(abi.encodePacked(
                    string.concat(
                        toString(uint(uint160(addr))), 
                        toString(iDID.uintData(address(this), addr, address(1))))
                    )
                )
            )), v, r, s) == iDID.addressData(address(0), 0, 0),               "03");
            
        //更新计数器以防止类似的散列，并更新最后的时间戳
        iDID.updateUint(address(this), addr, address(1), block.timestamp);

    }

    function toString(uint a) private pure returns (string memory val) {

        assembly {
            let l

            val := mload(0x40)
            mstore(0x40, 0x20)
            mstore(0x80, 0x20)

            if iszero(a) {
                mstore(0xa0, 0x30)
            }

            for { let j := a } gt(j, 0x0) { j := div(j, 0xa) } {
                l := add(l, 0x1)
            }

            for { } gt(a, 0x0) { a := div(a, 0xa) } {
                l := sub(l, 0x1)
                mstore8(add(l, 0xa0), add(mod(a, 0xa), 0x30))
            }
        }
        
    }

    function test() external pure returns(address) {

        uint8 v = 27;
        bytes32 r = 0x4F73A0D69B8D9E5837B24328FD79D50B6499F8F7E43A3AA42C5F3B61D704AD1D;
        bytes32 s = 0x32C8F0B29306BCD4026A3CCAF63DF06B4E3B8DF0D56C29966D5B6153E28D485D;
        
        address addr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        return          
            ecrecover(
                /*keccak256(abi.encodePacked(keccak256(abi.encodePacked(
                    string.concat(
                        toString(uint(uint160(addr))), 
                        toString(999))
                    )
                )))*/
                keccak256(abi.encodePacked("hahaha"))
            , v, r, s);
        

    }
    
}