// SPDX-License-Identifier:None
pragma solidity 0.8.23;
pragma abicoder v2;

import {Assert} from "remix_tests.sol";
import {Proxy} from "../Proxy.sol";
import {Item} from "../GameAsset/Item.sol";
import {GGC} from "../GameAsset/GGC.sol";
    
library Z {
    bytes4 constant public B4a = 0x80ac58cd;
    bytes4 constant public B4b = 0x5b5e139f;

    address constant public AC7 = 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7;
    address constant public AC9 = 0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC;
    address constant public ADM = 0xA34357486224151dDfDB291E13194995c22Df505;

    bytes32 constant public APP = 0x095ea7b300000000000000000000000000000000000000000000000000000000;
    bytes32 constant public AFA = 0xe985e9c500000000000000000000000000000000000000000000000000000001;
    bytes32 constant public AF2 = 0xe985e9c500000000000000000000000000000000000000000000000000000002;
    bytes32 constant public TFM = 0x23b872dd00000000000000000000000000000000000000000000000000000000;
    bytes32 constant public R = 0x451487bb930cb3bda5170b73cdbec957c7669592809de8a278256ac95fdf4cf4;
    bytes32 constant public S = 0x04fa784da9ad6f41766e09a789aaac8281cb68c7d8323b212a4675060181046d;
    bytes32 constant public R2 = 0x0ccfb6183f320d729454803b899292650e52a259ec5b0bbfa2650a916f413642;
    bytes32 constant public S2 = 0x33d6ba808c25541419deb2302fb2573595444d0fa59103142c8a32f5dc6ae958;

    string constant public STR = "ifps://QmNvWjdSxcXDzevFNYw46QkNvuTEod1FF8Le7GYLxWAavk";
    string constant public ST2 = "ifps://QmNvWjdSxcXDzevFNYw46QkNvuTEod1FF8Le7GYLxWA000";
    string constant public ST3 = "ifps://QmNvWjdSxcXDzevFNYw46QkNvuTEod1FF8Le7GYLxWA111";

    string constant public E02 = "adr>0";
    string constant public E03 = "name!=''";
    string constant public E04 = "sym!=''";
    string constant public E05 = "cnt=0";
    string constant public E06 = "inf";
    string constant public E07 = "TIS==0";
    string constant public E08 = "ID1==null";
    string constant public E09 = "uri.len==53";
    string constant public E10 = "sig!=0";
    string constant public E11 = "TIS>0";
    string constant public E12 = "ID1==TIS";
    string constant public E13 = "uri==STR";
    string constant public E14 = "TIS==0";
    string constant public E15 = "ID11==TIS";
    string constant public E16 = "AC9!=app";
    string constant public E17 = "AC9==app";
    string constant public E18 = "ID3==AC7";
    string constant public E19 = "AC7==0";
    string constant public E20 = "AC7==1";
    string constant public E21 = "TIS==1";
    string constant public E22 = "ID3==null";
    string constant public E23 = "AC7==1";
    string constant public E24 = "AC7==4";
    string constant public E25 = "TIS==7";
    string constant public E26 = "ID1==AC7";
    string constant public E27 = "TIS==6";
    string constant public E28 = "TIS==5";
    string constant public E29 = "uri==mer";
    string constant public E30 = "uri==upg";
    string constant public E31 = "should throw error";
    string constant public E32 = "ID9==0";
    string constant public E33 = "TIS==4";
    string constant public E34 = "AC7==5";
    string constant public E35 = "TIS==3";
    string constant public E36 = "AC7==6";
    string constant public E37 = "balance should increase";
    string constant public E38 = "balance should be amt";

    function resetCounter(Proxy a) public {
        bytes32 ptr;
        assembly {
            mstore(0x00, origin())
            ptr := add(keccak256(0x00, 0x20), 0x01)
        }
        a.mem(ptr, bytes32(0));
    }

    function toBytes32(address a) public pure returns (bytes32) {
        return bytes32(uint(uint160(a)));
    }

    function toBytes32(uint a) public pure returns (bytes32) {
        return bytes32(a);
    }

    function populatedSTR() public pure returns (string[] memory) {
        string[] memory str = new string[](10);
        for (uint i; i < 10; ++i) str[i] = Z.STR;
        return str;
    }
}