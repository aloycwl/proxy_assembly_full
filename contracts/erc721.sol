pragma solidity>0.8.0;//SPDX-License-Identifier:None

interface IERC721{
    event Transfer(address indexed from,address indexed to,uint indexed tokenId);
    event Approval(address indexed owner,address indexed approved,uint indexed tokenId);
    event ApprovalForAll(address indexed owner,address indexed operator,bool approved);
    function balanceOf(address)external view returns(uint);
    function ownerOf(uint)external view returns(address);
    function safeTransferFrom(address,address,uint)external;
    function transferFrom(address,address,uint)external;
    function approve(address,uint)external;
    function getApproved(uint)external view returns(address);
    function setApprovalForAll(address,bool)external;
    function isApprovedForAll(address,address)external view returns(bool);
    function safeTransferFrom(address,address,uint,bytes calldata)external;
}

interface IERC721Metadata{
    function name()external view returns(string memory);
    function symbol()external view returns(string memory);
    function tokenURI(uint)external view returns(string memory);
}

contract ERC721AC is IERC721,IERC721Metadata{
    address private _owner;
    mapping(uint=>address)private _owners;
    mapping(address=>uint)private _balances;
    mapping(uint=>address)private _tokenApprovals;
    mapping(address=>mapping(address=>bool))private _operatorApprovals;
    uint public Count;
    mapping(address=>mapping(uint=>uint))public _owned;

    /*
    Standard functions for ERC721
    ERC721基本函数 
    */
    constructor(){
        _owner=msg.sender;
    }
    function supportsInterface(bytes4 itf)external pure returns(bool){
        return itf==type(IERC721).interfaceId||itf==type(IERC721Metadata).interfaceId;
    }
    function balanceOf(address addr)external view returns(uint){
        return _balances[addr];
    }
    function ownerOf(uint id)external view returns(address){
        return _owners[id]; 
    }
    function owner()external view returns(address){
        return _owner;
    }
    function name()external pure returns(string memory){
        return "Wild Dynasty NFT";
    }
    function symbol()external pure returns(string memory){
        return "WD";
    }
    function tokenURI(uint _i)external pure returns(string memory){
        return string(abi.encodePacked("http://someipfs.com/",toString(_i)));
    }
    function approve(address to,uint id)public{
        require(msg.sender==_owners[id]||isApprovedForAll(_owners[id],msg.sender),"Invalid ownership");
        _tokenApprovals[id]=to;
        emit Approval(_owners[id],to,id);
    }
    function getApproved(uint id)public view returns(address){
        return _tokenApprovals[id];
    }
    function setApprovalForAll(address to,bool status)external{
        _operatorApprovals[msg.sender][to]=status;
        emit ApprovalForAll(msg.sender,to,status);
    }
    function isApprovedForAll(address from,address to)public view returns(bool){
        return _operatorApprovals[from][to];
    }
    function transferFrom(address from,address to,uint id)public{unchecked{
        require(msg.sender==_owners[id]||getApproved(id)==from||isApprovedForAll(_owners[id],from)||msg.sender==_owner
            ,"Invalid ownership");
        (_tokenApprovals[id]=address(0),_balances[from]--,_balances[to]++,_owners[id]=to);
        emit Approval(_owners[id],to,id);
        emit Transfer(from,to,id);
    }}
    function safeTransferFrom(address from,address to,uint id)external{
        transferFrom(from,to,id);
    }
    function safeTransferFrom(address from,address to,uint id,bytes memory)external{
        transferFrom(from,to,id);
    }

    /*
    Custom functions
    自定函数
    */
    function getOwned(address from)external view returns(uint[]memory _ids){
        _ids=new uint[](_balances[from]);
        for(uint i=0;i<_balances[from];i++)_ids[i]=_owned[from][i];
    }
    function Burn(uint id)external{unchecked{
        address addr=_owners[id];
        for(uint i=0;i<_balances[addr];i++)
            if(_owned[addr][i]==id){
                _owned[addr][i]=_owned[addr][_balances[_owners[id]]-1];
                delete _owned[addr][_balances[_owners[id]]-1];
                break;
            }
        transferFrom(addr,address(0),id);
        delete _owners[id];
    }}
    function Mint()external{unchecked{
        (_owners[Count],_owned[msg.sender][_balances[msg.sender]])=(msg.sender,Count);
        (Count++,_balances[msg.sender]++);
        emit Transfer(address(this),msg.sender,Count);
    }}
    function toString(uint _i)private pure returns(bytes memory bstr){unchecked{
        if(_i==0)return"0";
        uint j=_i;
        uint k;
        while(j>0)(k++,j/=10);
        (bstr,j)=(new bytes(k),k-1);
        while(_i>0)(bstr[j--]=bytes1(uint8(48+_i%10)),_i/=10);
        return bstr;
    }}
}