//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "/Contracts/Util/LibUint.sol";
import "/Contracts/Util/LibString.sol";
import "/Contracts/Interfaces.sol";

contract Sign {

    using LibUint   for uint;
    using LibString for string;

    IProxy internal iProxy;

    constructor(address proxy) {

        iProxy = IProxy(proxy);

    }

    function check(address addr, uint8 v, bytes32 r, bytes32 s) internal {

        IDID iDID = IDID(iProxy.addrs(3));                          //签名者用3号索引
        
        unchecked {

            require(
                ecrecover(           
                    uint(uint160(addr)).toString().
                        append(iDID.uintData(addr, 1).toString()).encode()
                    , v, r, s
                ) == iProxy.addrs(4),                               "Invalid signature");
            
            //更新计数器以防止类似的散列，并更新最后的时间戳
            iDID.updateUint(addr, 1, block.timestamp);

        }

    }
    
}