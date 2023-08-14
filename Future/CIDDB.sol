// SPDX-License-Identifier: None
pragma solidity 0.8.19;
pragma abicoder v1;

/*
A database to store the CID that could have been reused and
wasted the total storage space. This will be more effective
than ERC-1155 if the CID of the metadate is the same. Instead
of using at least 3 memory lines for string, CID database only
need 1 storage slot to fetch the CID or URL.

Store the CID with a return uint value if it does not exist.
The uint value will be used to call the fetch() function
which will return the string.
*/

contract CIDDB {
    mapping(string => uint) public search;
    mapping(uint => string) public fetch;
    bytes32 constant private CDB = 0x34b90c3fe4058816a5fd62fd112c01472c461559e126623d04d1af72d9ad437e;

    function setFetch(string memory cid) external returns(uint nwc) {
        require(CIDDB(address(this)).search(cid) == 0, "CID Existed");
        assembly {
            nwc := add(sload(CDB), 1)
            sstore(0x00, nwc)
        }
        search[cid] = nwc;
        fetch[nwc] = cid;
    }

    function count() external view returns(uint) {
        assembly {
            mstore(0x00, sload(CDB))
            return(0x00, 0x20)
        }
    }
}

