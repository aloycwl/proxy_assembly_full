pragma solidity>0.8.0;//SPDX-License-Identifier:None

struct UserOperation{
    address sender;uint nonce;bytes initCode;bytes callData;uint callGasLimit;uint verificationGasLimit;
    uint preVerificationGas;uint maxFeePerGas;uint maxPriorityFeePerGas;bytes paymasterAndData;bytes signature;
}
library UserOperationLib {
    function getSender(UserOperation calldata userOp)internal pure returns(address){
        address data;
        assembly {data:=calldataload(userOp)}
        return address(uint160(data));
    }
    function gasPrice(UserOperation calldata userOp)internal view returns(uint){unchecked{
        (uint maxFeePerGas,uint maxPriorityFeePerGas)=(userOp.maxFeePerGas,userOp.maxPriorityFeePerGas);
        return maxFeePerGas==maxPriorityFeePerGas?maxFeePerGas:min(maxFeePerGas,maxPriorityFeePerGas+block.basefee);
    }}
    function pack(UserOperation calldata userOp)internal pure returns(bytes memory ret){
        bytes calldata sig=userOp.signature;
        assembly{
            let ofs:=userOp
            let len:=sub(sub(sig.offset,ofs),32)
            ret:=mload(0x40)
            mstore(0x40,add(ret,add(len,32)))
            mstore(ret,len)
            calldatacopy(add(ret,32),ofs,len)
        }
    }
    function hash(UserOperation calldata userOp)internal pure returns(bytes32) {
        return keccak256(pack(userOp));
    }
    function min(uint a,uint b)internal pure returns(uint){
        return a<b?a:b;
    }
}

interface IPaymaster{
    enum PostOpMode{opSucceeded,opReverted,postOpReverted}
    function validatePaymasterUserOp(UserOperation calldata,bytes32,uint)
    external returns(bytes memory,uint);
    function postOp(PostOpMode,bytes calldata,uint)external;
}
interface IAccount{
    function validateUserOp(UserOperation calldata,bytes32,uint)
    external returns(uint);
}
interface IStakeManager {
    event Deposited(address,uint);
    event Withdrawn(address,address,uint);
    event StakeLocked(address,uint,uint);
    event StakeUnlocked(address,uint);
    event StakeWithdrawn(address,address,uint);
    struct DepositInfo{uint112 deposit;bool staked;uint112 stake;uint32 unstakeDelaySec;uint48 withdrawTime;}
    struct StakeInfo {uint stake;uint unstakeDelaySec;}
    function getDepositInfo(address)external view returns(DepositInfo memory);
    function balanceOf(address)external view returns(uint);
    function depositTo(address)external payable;
    function addStake(uint32)external payable;
    function unlockStake()external;
    function withdrawStake(address payable)external;
    function withdrawTo(address payable,uint) external;
}
interface IEntryPoint is IStakeManager{
    event UserOperationEvent(bytes32 ,address ,address,uint,bool,uint,uint);
    event AccountDeployed(bytes32,address,address,address);
    event UserOperationRevertReason(bytes32,address,uint,bytes);
    event SignatureAggregatorChanged(address);
    error FailedOp(uint,string);
    error SignatureValidationFailed(address);
    error ValidationResult(ReturnInfo,StakeInfo,StakeInfo,StakeInfo);
    error ValidationResultWithAggregation(ReturnInfo,StakeInfo,StakeInfo,StakeInfo,AggregatorStakeInfo);
    error SenderAddressResult(address);
    error ExecutionResult(uint,uint,uint48,uint48,bool,bytes);
    struct UserOpsPerAggregator{UserOperation[]userOps;IAggregator aggregator;bytes signature;}
    struct ReturnInfo{uint preOpGas;uint prefund;bool sigFailed;uint48 validAfter;uint48 validUntil;bytes paymasterContext;}
    struct AggregatorStakeInfo{address aggregator;StakeInfo stakeInfo;}
    function handleOps(UserOperation[]calldata,address payable)external;
    function handleAggregatedOps(UserOpsPerAggregator[]calldata,address payable)external;
    function getUserOpHash(UserOperation calldata)external view returns(bytes32);
    function simulateValidation(UserOperation calldata)external;
    function getSenderAddress(bytes memory initCode)external;
    function simulateHandleOp(UserOperation calldata, address,bytes calldata)external;
}
interface IAggregator{
    function validateSignatures(UserOperation[]calldata,bytes calldata)external view;
    function validateUserOpSignature(UserOperation calldata)external view returns(bytes memory);
    function aggregateSignatures(UserOperation[]calldata)external view returns(bytes memory);
}