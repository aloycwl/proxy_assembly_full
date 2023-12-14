// SPDX-License-Identifier: None
pragma solidity 0.8.23;
pragma abicoder v1;

import {GGC}    from "../GameAsset/GGC.sol";
import {Item}   from "../GameAsset/Item.sol";
import {Node}   from "../Governance/Node.sol";
import {Market} from "../Market.sol";
import {Proxy}  from "../Proxy.sol";
import {Hashes} from "../Util/Hashes.sol";

contract Deployer is Hashes {

    constructor(address adr) {
        (Proxy ggc, Proxy itm, Proxy nod, Proxy mkt) = 
            (new Proxy(address(new GGC())), new Proxy(address(new Item())),
            new Proxy(address(new Node())), new Proxy(address(new Market())));

        assembly {
            sstore(0x01, itm)
            sstore(0x02, ggc)
            sstore(0x03, nod)
            sstore(0x04, mkt)

            // GGC(address(ggc)).mint(nod, 1e24); 
            mstore(0x80, 0x40c10f1900000000000000000000000000000000000000000000000000000000)
            mstore(0x84, nod)
            mstore(0xa4, 0xd3c21bcecceda1000000)
            pop(call(gas(), ggc, 0x00, 0x80, 0x44, 0x00, 0x00))

            // Proxy(itm).mem(APP, adr); // signer = msg.sender
            mstore(0x80, 0xb88bab2900000000000000000000000000000000000000000000000000000000)
            mstore(0x84, APP)
            mstore(0xa4, adr)
            pop(call(gas(), itm, 0x00, 0x80, 0x44, 0x00, 0x00))

            // Proxy(nod).mem(APP, adr); // signer = msg.sender
            pop(call(gas(), nod, 0x00, 0x80, 0x44, 0x00, 0x00))

            /******* TEMP *******/
            // Proxy(itm).mem(AFA, ggc); // list[1] = ggc
            mstore(0x84, 0xe985e9c500000000000000000000000000000000000000000000000000000001)
            mstore(0xa4, ggc)
            pop(call(gas(), itm, 0x00, 0x80, 0x44, 0x00, 0x00))

            /******* TEMP *******/
            // Proxy(itm).mem(AFA, ggc); // list[2] = 4096
            mstore(0x84, 0xe985e9c500000000000000000000000000000000000000000000000000000002)
            mstore(0xa4, 0x1000)
            pop(call(gas(), itm, 0x00, 0x80, 0x44, 0x00, 0x00))

            // Proxy(nod).mem(shl(0x05, adr), 0x01) // games[adr] = 1
            mstore(0x84, shl(0x05, adr))
            mstore(0xa4, 0x01)
            pop(call(gas(), nod, 0x00, 0x80, 0x44, 0x00, 0x00))

            // Proxy(nod).mem(TTF, gg2); // GGC = ERC20 address
            mstore(0x84, TTF)
            mstore(0xa4, ggc)
            pop(call(gas(), nod, 0x00, 0x80, 0x44, 0x00, 0x00))

            // Proxy(nod).mem(TP5, it2); // top5 = Item address
            mstore(0x84, TP5)
            mstore(0xa4, itm)
            pop(call(gas(), nod, 0x00, 0x80, 0x44, 0x00, 0x00))

            // Proxy(nod).mem(adr << 5, true); // game(adr) = true // 加游戏
            mstore(0x84, shl(0x05, itm))
            mstore(0xa4, 0x01)
            pop(call(gas(), nod, 0x00, 0x80, 0x44, 0x00, 0x00))

            // Proxy(ggc).mem(OWO, adr);
            mstore(0x84, OWO)
            mstore(0xa4, adr)
            pop(call(gas(), ggc, 0x00, 0x80, 0x44, 0x00, 0x00)) // ggc.owner = msg.sender
            pop(call(gas(), itm, 0x00, 0x80, 0x44, 0x00, 0x00)) // itm.owner = msg.sender
            pop(call(gas(), nod, 0x00, 0x80, 0x44, 0x00, 0x00)) // nod.owner = msg.sender
            pop(call(gas(), mkt, 0x00, 0x80, 0x44, 0x00, 0x00)) // mkt.owner = msg.sender
        }
    }

    function contractAddresses() external view returns(address itm, address ggc, address nod, address mkt) {
        assembly {
            itm := sload(0x01)
            ggc := sload(0x02)
            nod := sload(0x03)
            mkt := sload(0x04)
        }
    }
}