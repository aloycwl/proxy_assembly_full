//SPDX-License-Identifier:None
pragma solidity 0.8.18;

import {LibString} from "Contracts/Util/LibString.sol";

contract Test {

    using LibString for string;

    function test() external pure returns (string memory) {

        string memory a = "a";
        string memory b = "b";

        return a.prepend(b);

    }

}