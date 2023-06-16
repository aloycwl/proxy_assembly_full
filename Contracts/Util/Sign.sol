//SPDX-License-Identifier:None
pragma solidity ^0.8.0;

import "Contracts/Util/LibUint.sol";
import "Contracts/Proxy.sol";
import "Contracts/DID.sol";

contract Sign {

    using LibUint for uint;

    Proxy internal iProxy;

    function check(address addr, uint8 v, bytes32 r, bytes32 s) internal {

        DID iDID = DID(iProxy.addrs(3));                      //签名者用3号索引
        
        require(          
            ecrecover(
                keccak256(abi.encodePacked(keccak256(abi.encodePacked(
                    string.concat(
                        uint(uint160(addr)).toString(), 
                        iDID.uintData(address(this), addr, address(1)).toString())
                    )
                )
            )), v, r, s) == iProxy.addrs(4),                    "Invalid signature");
            
        //更新计数器以防止类似的散列，并更新最后的时间戳
        iDID.updateUint(address(this), addr, address(1), block.timestamp);

    }
    
}