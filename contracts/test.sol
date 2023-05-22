// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Kill {
    constructor () payable {}
    fallback() external payable {}
    receive() external payable {}

    function kill () external {
        selfdestruct(payable(msg.sender));
    }
    function testCall() external pure returns (string memory) {
        return "Tst called";
    }
    function contractBal() external view returns (uint) {
        return address(this).balance;
    }
    function ownerBal() external view returns (uint) {
        return msg.sender.balance;
    }
}

contract Helper {
    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
    function kill(Kill _kill) external {
        _kill.kill();
    }
}