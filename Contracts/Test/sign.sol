//SPDX-License-Identifier:None
pragma solidity ^0.8.18;
pragma abicoder v1;

contract Sign {

    function test() external view returns(address) {

        uint8 v = 28;
        bytes32 r = 0x520c3ab3717abce7439b675837f11a8fc5a29949d4de0296d69a5b3d2b6a67c3;
        bytes32 s = 0x12516f02fb9fc134651d19e976c375c1d498a20588ee9d8313a30b2646ba590b;        
        address addr = 0xA34357486224151dDfDB291E13194995c22Df505;
        uint counter = 1689037672;

        //0xD153736BD16F2A5245Bf03f277281FF41afFaF9C
        //0x42F12c6f14F42c98290444608386E4713F3d83Ef

        return          
            ecrecover(
                keccak256(abi.encodePacked(keccak256(abi.encodePacked(
                    string.concat(
                        this.toString(uint(uint160(addr))), 
                        this.toString(counter))
                    )
                )))
            , v, r, s);
        

    }

    function concat() public view returns(string memory) {
        address addr = 0xA34357486224151dDfDB291E13194995c22Df505;
        uint counter = 1689037672;

        return string.concat(
            this.toString(uint(uint160(addr))), 
            this.toString(counter));
    }

    function toString(address a) public pure returns(string memory) {

        assembly {
            let l

            mstore(0x60, 0x20)
            mstore(0x80, 0x40)

            if iszero(a) {
                mstore(0xa0, 0x30)
            }

            for { let j := a } gt(j, 0x0) { j := div(j, 0xa) } {
                l := add(l, 0x1)
            }

            for { } gt(a, 0x0) { a := div(a, 0xa) } {
                l := sub(l, 0x1)
                mstore8(add(l, 0xa0), add(mod(a, 0xa), 0x30))
            }

            return(0x60, 0x80)
        }
        
    }

    function toString(uint a) public pure returns(string memory) {

        assembly {
            let l

            mstore(0x60, 0x20)
            mstore(0x80, 0x20)

            if iszero(a) {
                mstore(0xa0, 0x30)
            }

            for { let j := a } gt(j, 0x0) { j := div(j, 0xa) } {
                l := add(l, 0x1)
            }

            for { } gt(a, 0x0) { a := div(a, 0xa) } {
                l := sub(l, 0x1)
                mstore8(add(l, 0xa0), add(mod(a, 0xa), 0x30))
            }

            return(0x60, 0x60)
            
        }
        
    }

}