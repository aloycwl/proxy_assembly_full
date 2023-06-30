//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

//被调用的接口

interface IERC721 {

    event    Transfer (address indexed from, address indexed to, uint indexed tokenId);
    event    Approval (address indexed owner, address indexed approved, uint indexed tokenId);
    event    ApprovalForAll (address indexed owner, address indexed operator, bool approved);
    event    MetadataUpdate (uint);
    function balanceOf (address)                                        external view returns (uint);
    function ownerOf (uint)                                             external view returns (address);
    function safeTransferFrom (address, address, uint)                  external;
    function transferFrom (address, address, uint)                      external;
    function approve (address, uint)                                    external;
    function getApproved (uint)                                         external view returns (address);
    function setApprovalForAll (address, bool)                          external;
    function isApprovedForAll (address, address)                        external view returns (bool);
    function safeTransferFrom (address, address, uint, bytes calldata)  external;

}

interface IERC721Metadata {

    function name ()                                                    external view returns (string memory);
    function symbol ()                                                  external view returns (string memory);
    function tokenURI (uint)                                            external view returns (string memory);

}