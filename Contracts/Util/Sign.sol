//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import {LibUint} from "Contracts/Util/LibUint.sol";
import {DID}     from "Contracts/DID.sol";

contract Sign is DID {

    using LibUint for uint;

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
                        uint(uint160(addr)).toString(), 
                        iDID.uintData(address(this), addr, address(1)).toString())
                    )
                )
            )), v, r, s) == iDID.addressData(address(0), 0, 0),               "03");
            
        //更新计数器以防止类似的散列，并更新最后的时间戳
        iDID.updateUint(address(this), addr, address(1), block.timestamp);

    }
    
}