pragma solidity 0.8.4;//SPDX-License-Identifier:None



contract a{
    mapping(uint => bytes) private aa;

    function setAA(string calldata b, uint c)external{
        aa[c] = abi.encode(b);
    }

    function getAA(uint c)external view returns (string memory) {
        return abi.decode(aa[c], (string));
    }
}