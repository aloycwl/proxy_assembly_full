pragma solidity>0.8.0;//SPDX-License-Identifier:None

library BoringMath{
    function add(uint a,uint b)internal pure returns(uint c){
        require((c=a+b)>=b,"BoringMath: Add Overflow");
    }
    function sub(uint a,uint b)internal pure returns(uint c){
        require((c=a-b)<=a,"BoringMath: Underflow");
    }
    function mul(uint a,uint b)internal pure returns(uint c){
        require(b==0||(c=a*b)/b==a,"BoringMath: Mul Overflow");
    }
    function to128(uint a)internal pure returns(uint128 c){
        require(a<=type(uint128).max,"BoringMath: uint128 Overflow");
        c=uint128(a);
    }
    function to64(uint a)internal pure returns(uint64 c){
        require(a<=type(uint64).max,"BoringMath: uint64 Overflow");
        c=uint64(a);
    }
    function to32(uint a)internal pure returns(uint32 c){
        require(a<=type(uint32).max,"BoringMath: uint32 Overflow");
        c=uint32(a);
    }
}
library BoringMath128{
    function add(uint128 a,uint128 b)internal pure returns(uint128 c){
        require((c=a+b)>=b,"BoringMath: Add Overflow");
    }
    function sub(uint128 a,uint128 b)internal pure returns(uint128 c){
        require((c=a-b)<=a,"BoringMath: Underflow");
    }
}
library BoringMath64{
    function add(uint64 a,uint64 b)internal pure returns(uint64 c){
        require((c=a+b)>=b,"BoringMath: Add Overflow");
    }
    function sub(uint64 a,uint64 b)internal pure returns(uint64 c){
        require((c=a-b)<=a,"BoringMath: Underflow");
    }
}
library BoringMath32{
    function add(uint32 a,uint32 b)internal pure returns(uint32 c){
        require((c=a+b)>=b,"BoringMath: Add Overflow");
    }
    function sub(uint32 a,uint32 b)internal pure returns(uint32 c){
        require((c=a-b)<=a,"BoringMath: Underflow");
    }
}
interface IERC20{
    function totalSupply()external view returns(uint);
    function balanceOf(address)external view returns(uint);
    function allowance(address,address)external view returns(uint);
    function approve(address,uint)external returns(bool);
    function permit(address,address,uint,uint,uint8,bytes32,bytes32)external;
    event Transfer(address indexed from,address indexed to,uint value);
    event Approval(address indexed owner,address indexed spender,uint value);
}

contract Domain{
    bytes32 private constant DOMAIN_SEPARATOR_SIGNATURE_HASH=keccak256("EIP712Domain(uint chainId,address verifyingContract)");
    string private constant EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA="\x19\x01";
    bytes32 private immutable _DOMAIN_SEPARATOR;
    uint private immutable DOMAIN_SEPARATOR_CHAIN_ID;
    function _calculateDomainSeparator(uint chainId)private view returns(bytes32){
        return keccak256(abi.encode(DOMAIN_SEPARATOR_SIGNATURE_HASH,chainId,address(this)));
    }
    constructor(){
        uint chainId;
        assembly{
            chainId :=chainid()
        }
        _DOMAIN_SEPARATOR=_calculateDomainSeparator(DOMAIN_SEPARATOR_CHAIN_ID=chainId);
    }
    function _domainSeparator()internal view returns(bytes32){
        uint chainId;
        assembly{
            chainId :=chainid()
        }
        return chainId==DOMAIN_SEPARATOR_CHAIN_ID ? _DOMAIN_SEPARATOR : _calculateDomainSeparator(chainId);
    }
    function _getDigest(bytes32 dataHash)internal view returns(bytes32 digest){
        digest=keccak256(abi.encodePacked(EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA,_domainSeparator(),dataHash));
    }
}

contract ERC20Data{
    mapping(address=> uint)public balanceOf;
    mapping(address=> mapping(address=> uint))public allowance;
    mapping(address=> uint)public nonces;
}

abstract contract ERC20 is IERC20,Domain{
    mapping(address=> uint)public override balanceOf;
    mapping(address=> mapping(address=> uint))public override allowance;
    mapping(address=> uint)public nonces;
    function transfer(address to,uint amount)public returns(bool){
        return transferFrom(msg.sender,to,amount);
    }
    function transferFrom(address from,address to,uint amount)public returns(bool){
        if(amount!=0){
            uint srcBalance=balanceOf[from];
            require(srcBalance>=amount,"ERC20: balance too low");
            if(from!=to){
                uint spenderAllowance=allowance[from][msg.sender];
                if(spenderAllowance!=type(uint).max){
                    require(spenderAllowance>=amount,"ERC20: allowance too low");
                    allowance[from][msg.sender]=spenderAllowance-amount;
                }
                require(to!=address(0),"ERC20: no zero address");//Moved down so other failed calls safe some gas
                balanceOf[from]=srcBalance-amount;
                balanceOf[to]+=amount;
            }
        }
        emit Transfer(from,to,amount);
        return true;
    }
    function approve(address spender,uint amount)public override returns(bool){
        allowance[msg.sender][spender]=amount;
        emit Approval(msg.sender,spender,amount);
        return true;
    }
    function DOMAIN_SEPARATOR()external view returns(bytes32){
        return _domainSeparator();
    }
    bytes32 private constant PERMIT_SIGNATURE_HASH=0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    function permit(address owner_,address spender,uint value,uint deadline,uint8 v,bytes32 r,bytes32 s)external override{
        require(owner_!=address(0),"ERC20: Owner cannot be 0");
        require(block.timestamp<deadline,"ERC20: Expired");
        require(ecrecover(_getDigest(keccak256(abi.encode(PERMIT_SIGNATURE_HASH,owner_,spender,value,nonces[owner_]++,deadline))),v,r,s)
            ==owner_,"ERC20: Invalid Signature");
        allowance[owner_][spender]=value;
        emit Approval(owner_,spender,value);
    }
}

contract ERC20WithSupply is IERC20,ERC20{
    uint public override totalSupply;
    function _mint(address user,uint amount)private{
        uint newTotalSupply=totalSupply+amount;
        require(newTotalSupply>=totalSupply,"Mint overflow");
        (totalSupply=newTotalSupply,balanceOf[user]+=amount);
    }
    function _burn(address user,uint amount)private{
        require(balanceOf[user]>=amount,"Burn too much");
        (totalSupply-=amount,balanceOf[user]-=amount);
    }
}

struct Rebase{
    uint128 elastic;
    uint128 base;
}

library RebaseLibrary{
    using BoringMath for uint;
    using BoringMath128 for uint128;
    function toBase(Rebase memory total,uint elastic,bool roundUp)internal pure returns(uint base){
        if(total.elastic==0)base=elastic;
        else{
            base=elastic.mul(total.base)/total.elastic;
            if(roundUp&&base.mul(total.elastic)/total.base<elastic)base=base.add(1);
        }
    }
    function toElastic(Rebase memory total,uint base,bool roundUp)internal pure returns(uint elastic){
        if(total.base==0)elastic=base;
        else{
            elastic=base.mul(total.elastic)/total.base;
            if(roundUp&&elastic.mul(total.base)/total.elastic<base)elastic=elastic.add(1);
        }
    }
    function add(Rebase memory total,uint elastic,bool roundUp)internal pure returns(Rebase memory,uint base){
        base=toBase(total,elastic,roundUp);
        (total.elastic,total.base)=(total.elastic.add(elastic.to128()),total.base.add(base.to128()));
        return (total,base);
    }
    function sub(Rebase memory total,uint base,bool roundUp)internal pure returns(Rebase memory,uint elastic){
        elastic=toElastic(total,base,roundUp);
        total.elastic=total.elastic.sub(elastic.to128());
        total.base=total.base.sub(base.to128());
        return (total,elastic);
    }
    function add(Rebase memory total,uint elastic,uint base)internal pure returns(Rebase memory){
        (total.elastic,total.base)=(total.elastic.add(elastic.to128()),total.base.add(base.to128()));
        return total;
    }
    function sub(Rebase memory total,uint elastic,uint base)internal pure returns(Rebase memory){
        (total.elastic,total.base)=(total.elastic.sub(elastic.to128()),total.base.sub(base.to128()));
        return total;
    }
    function addElastic(Rebase storage total,uint elastic)internal returns(uint){
        return total.elastic=total.elastic.add(elastic.to128());
    }
    function subElastic(Rebase storage total,uint elastic)internal returns(uint){
        return total.elastic=total.elastic.sub(elastic.to128());
    }
}

interface IBatchFlashBorrower{
    function onBatchFlashLoan(address,IERC20[]calldata,uint[]calldata,uint[]calldata,bytes calldata)external;
}
interface IFlashBorrower{
    function onFlashLoan(address,IERC20,uint,uint,bytes calldata)external;
}
interface IStrategy{
    function skim(uint)external;
    function harvest(uint,address)external returns(int256);
    function withdraw(uint)external returns(uint);
    function exit(uint)external returns(int256);
}
interface IBentoBoxV1{
    event LogDeploy(address indexed masterContract,bytes data,address indexed cloneAddress);
    event LogDeposit(address indexed token,address indexed from,address indexed to,uint amount,uint share);
    event LogFlashLoan(address indexed borrower,address indexed token,uint amount,uint feeAmount,address indexed receiver);
    event LogRegisterProtocol(address indexed protocol);
    event LogSetMasterContractApproval(address indexed masterContract,address indexed user,bool approved);
    event LogStrategyDivest(address indexed token,uint amount);
    event LogStrategyInvest(address indexed token,uint amount);
    event LogStrategyLoss(address indexed token,uint amount);
    event LogStrategyProfit(address indexed token,uint amount);
    event LogStrategyQueued(address indexed token,address indexed strategy);
    event LogStrategySet(address indexed token,address indexed strategy);
    event LogStrategyTargetPercentage(address indexed token,uint targetPercentage);
    event LogTransfer(address indexed token,address indexed from,address indexed to,uint share);
    event LogWhiteListMasterContract(address indexed masterContract,bool approved);
    event LogWithdraw(address indexed token,address indexed from,address indexed to,uint amount,uint share);
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

    function balanceOf(IERC20,address)external view returns(uint);
    function batch(bytes[]calldata,bool)external payable returns(bool[]memory,bytes[]memory);
    function batchFlashLoan(IBatchFlashBorrower,address[]calldata,IERC20[]calldata,uint[]calldata,bytes calldata)external;
    function claimOwnership()external;
    function deploy(address,bytes calldata,bool)external payable;
    function deposit(IERC20,address,address,uint,uint)external payable returns(uint,uint);
    function flashLoan(IFlashBorrower,address,IERC20,uint,bytes calldata)external;
    function harvest(IERC20,bool,uint)external;
    function masterContractApproved(address,address)external view returns(bool);
    function masterContractOf(address)external view returns(address);
    function nonces(address)external view returns(uint);
    function owner()external view returns(address);
    function pendingOwner()external view returns(address);
    function pendingStrategy(IERC20)external view returns(IStrategy);
    function permitToken(IERC20,address,address,uint,uint,uint8,bytes32,bytes32)external;
    function registerProtocol()external;
    function setMasterContractApproval(address,address,bool,uint8,bytes32,bytes32)external;
    function setStrategy(IERC20,IStrategy)external;
    function setStrategyTargetPercentage(IERC20,uint64)external;
    function strategy(IERC20)external view returns(IStrategy);
    function strategyData(IERC20)external view returns(uint64,uint64,uint128);
    function toAmount(IERC20,uint,bool)external view returns(uint);
    function toShare(IERC20,uint,bool)external view returns(uint);
    function totals(IERC20)external view returns(Rebase memory);
    function transfer(IERC20,address,address,uint)external;
    function transferMultiple(IERC20,address,address[]calldata,uint[]calldata)external;
    function transferOwnership(address,bool,bool)external;
    function whitelistMasterContract(address,bool)external;
    function whitelistedMasterContracts(address)external view returns(bool);
    function withdraw(IERC20,address,address,uint,uint)external returns(uint,uint);
}

contract BoringOwnable{
    address public owner;
    address public pendingOwner;
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);
    constructor(){
        owner=msg.sender;
        emit OwnershipTransferred(address(0),msg.sender);
    }
    function transferOwnership(address newOwner,bool direct,bool renounce)public onlyOwner{
        if(direct){
            require(newOwner!=address(0)||renounce,"Ownable: zero address");
            emit OwnershipTransferred(owner,newOwner);
            (owner,pendingOwner)=(newOwner,address(0));
        }else pendingOwner=newOwner;
    }
    function claimOwnership()public{
        address _pendingOwner=pendingOwner;
        require(msg.sender==_pendingOwner,"Ownable: caller!=pending owner");
        emit OwnershipTransferred(owner,_pendingOwner);
        (owner,pendingOwner)=(_pendingOwner,address(0));
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"Ownable: caller is not the owner");_;
    }
}

contract MagicInternetMoneyV1 is ERC20,BoringOwnable{
    using BoringMath for uint;
    string public constant symbol="MIM";
    string public constant name="Magic Internet Money";
    uint8 public constant decimals=18;
    uint public override totalSupply;
    struct Minting{
        uint128 time;
        uint128 amount;
    }
    Minting public lastMint;
    uint private constant MINTING_PERIOD=24 hours;
    uint private constant MINTING_INCREASE=15000;
    uint private constant MINTING_PRECISION=1e5;
    function mint(address to,uint amount)public onlyOwner{
        require(to!=address(0),"MIM: no mint to zero address");
        uint totalMintedAmount=uint(lastMint.time<block.timestamp-MINTING_PERIOD ? 0 : lastMint.amount).add(amount);
        require(totalSupply==0||totalSupply.mul(MINTING_INCREASE)/MINTING_PRECISION>=totalMintedAmount);
        (lastMint.time,lastMint.amount)=(block.timestamp.to128(),totalMintedAmount.to128());
        (totalSupply+=amount,balanceOf[to]+=amount);
        emit Transfer(address(0),to,amount);
    }
    function mintToBentoBox(address clone,uint amount,IBentoBoxV1 bentoBox)public onlyOwner{
        mint(address(bentoBox),amount);
        bentoBox.deposit(IERC20(address(this)),address(bentoBox),clone,amount,0);
    }
    function burn(uint amount)public{
        require(amount<=balanceOf[msg.sender],"MIM: not enough");
        (balanceOf[msg.sender]-=amount,totalSupply-=amount);
        emit Transfer(msg.sender,address(0),amount);
    }
}