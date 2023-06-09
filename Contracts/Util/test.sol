//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import "/Contracts/Util/UintLib.sol";

contract Test {

    using UintLib for uint;

    function TEST() public pure returns(string memory) {

        uint abc = 999;

        return abc.toString();

    }

    function TEST2() public pure returns(uint) {

        uint abc = 1000;

        return abc.minusPercent(40000);

    }

}