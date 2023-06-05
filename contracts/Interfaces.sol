//SPDX-License-Identifier:None
pragma solidity 0.8.18;

//被调用的接口
interface IERC20 {

    function transfer(address, uint) external returns (bool);
    function setAccess(address, uint) external;

}

interface IDID {

    function did(string calldata) external view returns (address);
    function uintData(address, uint) external view returns (uint);
    function updateDid(string calldata, address) external;
    function updateUint(address, uint, uint) external;
    function updateString(address, uint, string calldata) external;
    function setAccess(address, uint) external;

}

interface IProxy {

    function addrs(uint) external view returns (address);
    function setAddr(address, uint) external;
    function setAccess(address, uint) external;

}

interface IGameEngine {

    function setAccess(address, uint) external;

}

interface IERC721 {

    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address) external view returns (uint);
    function ownerOf(uint) external view returns (address);
    function safeTransferFrom(address, address, uint) external;
    function transferFrom(address, address, uint) external;
    function approve(address, uint) external;
    function getApproved(uint) external view returns (address);
    function setApprovalForAll(address, bool) external;
    function isApprovedForAll(address, address) external view returns (bool);
    function safeTransferFrom(address, address, uint, bytes calldata) external;

}

interface IERC721Metadata {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint) external view returns (string memory);
    
}