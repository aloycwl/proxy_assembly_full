//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

import {LibUint} from "Contracts/Util/LibUint.sol";
import {Proxy}   from "Contracts/Proxy.sol";
import {DID}     from "Contracts/DID.sol";

contract Sign {

    using LibUint for uint;

    Proxy private iProxy;

    constructor(address proxy) {

        iProxy = Proxy(proxy);

    }

    function check(address addr, uint8 v, bytes32 r, bytes32 s) internal {

        DID iDID = DID(iProxy.addrs(3));     //签名者用3号索引
        
        require(          
            ecrecover(
                keccak256(abi.encodePacked(keccak256(abi.encodePacked(
                    string.concat(
                        uint(uint160(addr)).toString(), 
                        iDID.uintData(address(this), addr, address(1)).toString())
                    )
                )
            )), v, r, s) == iProxy.addrs(4), "Invalid signature");
            
        //更新计数器以防止类似的散列，并更新最后的时间戳
        iDID.updateUint(address(this), addr, address(1), block.timestamp);

    }
    
}