//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "./Util.sol";
import "./Interfaces.sol";

struct User{
    uint bal;
    mapping(uint => uint) nfts;
    mapping(address => bool) opApp;
    bool blocked;
}

contract ERC721 is IERC721, IERC721Metadata, Util {
    address private _owner;
    mapping (uint => address) private _owners;
    mapping (uint => address) private _tokenApprovals;
    uint public Count;
    bool public Suspended;
    string public constant symbol = "WDNFT";
    string public constant name = "Wild Dynasty NFT";
    mapping (address => User) public u;

    //ERC721基本函数 
    function supportsInterface(bytes4 itf)external pure returns(bool){
        return itf==type(IERC721).interfaceId||itf==type(IERC721Metadata).interfaceId;
    }
    function balanceOf(address addr)external view returns(uint){
        require(!u[addr].blocked,"Suspended");
        return u[addr].bal;
    }
    function ownerOf(uint id)external view returns(address){
        require(!u[_owners[id]].blocked,"Suspended");
        return _owners[id]; 
    }
    function owner()external view returns(address){
        return _owner;
    }
    function tokenURI(uint _i)external view returns(string memory){
        unchecked{
            assert(_i<Count);
            bytes memory bstr;
            if(_i==0)bstr="0";
            else{
                uint j=_i;
                uint k;
                while(j>0)(k++,j/=10);
                (bstr,j)=(new bytes(k),k-1);
                while(_i>0)(bstr[j--]=bytes1(uint8(48+_i%10)),_i/=10);
            }
            return string(abi.encodePacked("http://someipfs.com/",bstr));
        }
    }
    function approve (address to, uint id) public {
        require(msg.sender==_owners[id] || isApprovedForAll(_owners[id], msg.sender), "Invalid ownership");
        _tokenApprovals[id] = to;
        emit Approval(_owners[id], to, id);
    }
    function getApproved(uint id)public view returns(address){
        return _tokenApprovals[id];
    }
    function setApprovalForAll(address to, bool status) external {
        u[msg.sender].opApp[to] = status;
        emit ApprovalForAll(msg.sender, to, status);
    }
    function isApprovedForAll(address from, address to) public view returns (bool) {
        return u[from].opApp[to];
    }
    function transferFrom(address from,address to,uint id) public {
        unchecked {
            require(msg.sender==_owners[id] || 
                getApproved(id)==from ||
                isApprovedForAll(_owners[id],from) || 
                msg.sender==_owner ,"Invalid ownership");
            require(!Suspended&&!u[from].blocked, "Suspended");

            (_tokenApprovals[id] = address(0), --u[from].bal, ++u[to].bal, _owners[id] = to);
            emit Approval(_owners[id], to, id);
            emit Transfer(from, to, id);
        }
    }
    function safeTransferFrom(address from, address to, uint id) external {
        transferFrom(from, to, id);
    }
    function safeTransferFrom(address from, address to, uint id, bytes memory) external {
        transferFrom(from, to, id);
    }

    /*
    Custom functions
    自定函数
    */
    function getTokensOwned(address addr)external view returns(uint[]memory _ids){
        require(!u[addr].blocked,"Suspended");
        _ids = new uint[](u[addr].bal);
        for(uint i; i<u[addr].bal; ++i) _ids[i] = u[addr].nfts[i];
    }
    function Burn(uint id) external {
        unchecked{
            address addr = _owners[id];
            for(uint i = 0; i < u[addr].bal; ++i)
                if(u[addr].nfts[i] == id) {
                    u[addr].nfts[i] = u[addr].nfts[u[_owners[id]].bal - 1];
                    delete u[addr].nfts[u[_owners[id]].bal - 1];
                    break;
                }
            transferFrom(addr,address(0), id);
            delete _owners[id];
        }
    }
    function Mint() external {
        unchecked {
            require(!u[msg.sender].blocked, "Suspended");
            (_owners[Count], u[msg.sender].nfts[u[msg.sender].bal]) = (msg.sender, Count);
            ++u[msg.sender].bal;
            emit Transfer(address(this), msg.sender, Count++);
        }
    }
    function ToggleBlock(address addr) external OnlyAccess {
        u[addr].blocked=!u[addr].blocked;
    }
    function ToggleSuspend() external OnlyAccess {
        Suspended = Suspended ? false : true;
    }
}