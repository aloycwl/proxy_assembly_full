pragma solidity>0.8.0;//SPDX-License-Identifier:None

contract MagicInternetMoneyV1{
    event Transfer(address indexed from,address indexed to,uint value);
    event Approval(address indexed owner,address indexed spender,uint value);
    mapping(address=> uint)public balanceOf;
    mapping(address=> mapping(address=> uint))public allowance;
    mapping(address=> uint)public nonces;
    bytes32 private _DOMAIN_SEPARATOR;
    uint private DOMAIN_SEPARATOR_CHAIN_ID;
    string public constant symbol="MIM";
    string public constant name="Magic Internet Money";
    address public owner;
    address public pendingOwner;
    uint public constant decimals=18;
    uint public totalSupply;
    uint lastTime;
    uint lastAmount;
    modifier onlyOwner(){
        require(msg.sender==owner,"Ownable:caller is not the owner");_;
    }

    constructor(){
        owner=msg.sender;
        uint chainId;
        assembly{
            chainId:=chainid()
        }
        _DOMAIN_SEPARATOR=_calculateDomainSeparator(DOMAIN_SEPARATOR_CHAIN_ID=chainId);
    }
    function _calculateDomainSeparator(uint chainId)private view returns(bytes32){
        return keccak256(abi.encode(keccak256("EIP712Domain(uint chainId,address verifyingContract)"),chainId,address(this)));
    }
    function _domainSeparator()public view returns(bytes32){
        uint chainId;
        assembly{
            chainId:=chainid()
        }
        return chainId==DOMAIN_SEPARATOR_CHAIN_ID?_DOMAIN_SEPARATOR:_calculateDomainSeparator(chainId);
    }
    function transfer(address to,uint amount)public returns(bool){
        return transferFrom(msg.sender,to,amount);
    }
    function transferFrom(address from,address to,uint amount)public returns(bool){
        if(amount!=0){
            uint srcBalance=balanceOf[from];
            require(srcBalance>=amount,"ERC20:balance too low");
            if(from!=to){
                uint spenderAllowance=allowance[from][msg.sender];
                if(spenderAllowance!=type(uint).max){
                    require(spenderAllowance>=amount,"ERC20:allowance too low");
                    allowance[from][msg.sender]=spenderAllowance-amount;
                }
                require(to!=address(0),"ERC20:no zero address");//Moved down so other failed calls safe some gas
                balanceOf[from]=srcBalance-amount;
                balanceOf[to]+=amount;
            }
        }
        emit Transfer(from,to,amount);
        return true;
    }
    function approve(address spender,uint amount)public returns(bool){
        allowance[msg.sender][spender]=amount;
        emit Approval(msg.sender,spender,amount);
        return true;
    }
    function permit(address owner_,address spender,uint value,uint deadline,uint8 v,bytes32 r,bytes32 s)external{
        require(owner_!=address(0),"ERC20:Owner cannot be 0");
        require(block.timestamp<deadline,"ERC20:Expired");
        require(ecrecover(keccak256(abi.encodePacked("\x19\x01",_domainSeparator(),
            (keccak256(abi.encode(0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9,
            owner_,spender,value,nonces[owner_]++,deadline))))),v,r,s)==owner_,"ERC20:Invalid Signature");
        allowance[owner_][spender]=value;
        emit Approval(owner_,spender,value);
    }
    function mint(address to,uint amount)public onlyOwner{unchecked{
        require(to!=address(0),"No mint to zero address");
        uint totalMintedAmount=lastTime<block.timestamp-24 hours?0:lastAmount+amount;
        require(totalSupply==0||totalSupply*3/20>=totalMintedAmount);
        (lastTime,lastAmount)=(block.timestamp,totalMintedAmount);
        (totalSupply+=amount,balanceOf[to]+=amount);
        emit Transfer(address(0),to,amount);
    }}
    function burn(uint amount)public{unchecked{
        require(amount<=balanceOf[msg.sender],"Not enough");
        (balanceOf[msg.sender]-=amount,totalSupply-=amount);
        emit Transfer(msg.sender,address(0),amount);
    }}
}