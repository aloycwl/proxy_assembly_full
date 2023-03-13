pragma solidity>0.8.0;//SPDX-License-Identifier:None

contract Verify {
    function VerifyMessage(bytes32 _h,uint8 _v,bytes32 _r,bytes32 _s)external pure returns(address){
        return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",_h)),_v,_r,_s);
    }
}