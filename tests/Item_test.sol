// SPDX-License-Identifier:None
pragma solidity 0.8.23;
pragma abicoder v2;

import "../tests/lib_item.sol";

contract item_test {
    Item private itm;
    GGC private ggc;
    Proxy private pxy;
    Proxy private px2;
    address immutable TIS = address(this);

    function checkProxy() public {
        ggc = GGC(address(px2 = new Proxy(address(new GGC()))));
        Assert.notEqual(address(itm = Item(address(pxy = new Proxy(address(new Item()))))), address(0), Z.E02);
    }

    function checkStandards() public {
        Assert.notEqual(itm.name(), "", Z.E03);
        Assert.notEqual(itm.symbol(), "", Z.E04);
        Assert.equal(itm.count(), 0, Z.E05);
        Assert.ok(itm.supportsInterface(Z.B4a) && itm.supportsInterface(Z.B4b), Z.E06);
    }

    function checkBeforeMint() public {
        Assert.equal(itm.balanceOf(TIS), 0, Z.E07);
        Assert.equal(itm.ownerOf(1), address(0), Z.E08);
        Assert.equal(bytes(itm.tokenURI(1)).length, 53, Z.E09);
    }

    function checkSetSigner() public {
        bytes32 byt = Z.toBytes32(Z.ADM);
        pxy.mem(Z.APP, byt);
        Assert.equal(pxy.mem(Z.APP), byt, Z.E10); 
    }

    function checkMint() public {
        string[] memory str = new string[](1);
        str[0] = Z.STR;
        itm.mint(0, str, 27, Z.R, Z.S);
        Assert.equal(itm.balanceOf(TIS), 1, Z.E11);
        Assert.equal(itm.ownerOf(1), TIS, Z.E12);
        Assert.equal(itm.tokenURI(1), str[0], Z.E13);
    }

    function checkMint10() public {
        Z.resetCounter(pxy);
        itm.mint(0, Z.populatedSTR(), 27, Z.R, Z.S);
        Assert.equal(itm.balanceOf(TIS), 11, Z.E14);
        Assert.equal(itm.ownerOf(11), TIS, Z.E15);
    }

    function checkApproval() public {
        Assert.ok(!itm.isApprovedForAll(TIS, Z.AC9), Z.E16);
        itm.setApprovalForAll(Z.AC9, true);
        Assert.ok(itm.isApprovedForAll(TIS, Z.AC9), Z.E17);
        itm.approve(Z.AC7, 3);
        Assert.equal(itm.getApproved(3), Z.AC7, Z.E18);
    }

    function checkApproveReset() public {
        Assert.equal(itm.balanceOf(Z.AC7), 0, Z.E19);
        itm.transferFrom(TIS, Z.AC7, 3);
        Assert.equal(itm.balanceOf(Z.AC7), 1, Z.E20);
        Assert.equal(itm.balanceOf(TIS), 10, Z.E21);
        Assert.equal(itm.getApproved(3), address(0), Z.E22);
    }

    function checkTransferFrom() public {
        Assert.equal(itm.balanceOf(Z.AC7), 1, Z.E23);
        itm.transferFrom(TIS, Z.AC7, 1);
        itm.safeTransferFrom(TIS, Z.AC7, 2);
        itm.safeTransferFrom(TIS, Z.AC7, 4, new bytes(1));
        Assert.equal(itm.balanceOf(Z.AC7), 4, Z.E24);
        Assert.equal(itm.balanceOf(TIS), 7, Z.E25);
        Assert.equal(itm.ownerOf(1), Z.AC7, Z.E26);
    } 

    function checkBurn() public {
        itm.burn(9);
        Assert.equal(itm.balanceOf(TIS), 6, Z.E27);
        Assert.equal(itm.ownerOf(9), address(0), Z.E32);
    }

    function checkMerge() public {
        Z.resetCounter(pxy);
        uint[] memory ids = new uint[](2);
        (ids[0], ids[1]) = (5, 6);
        string memory mer = Z.ST2;
        itm.merge(ids, 0, mer, 27, Z.R, Z.S);
        Assert.equal(itm.balanceOf(TIS), 5, Z.E28);
        Assert.equal(itm.tokenURI(12), mer, Z.E29);
    }

    function checkUpgrade() public {
        Z.resetCounter(pxy);
        string memory upg = Z.ST3;
        itm.upgrade(0, 11, upg, 27, Z.R, Z.S);
        Assert.equal(itm.tokenURI(11), upg, Z.E30);
    }

    function checkUserSuspendFail() public {
        pxy.mem(Z.toBytes32(TIS), Z.toBytes32(1));
        try itm.transferFrom(TIS, Z.AC7, 7) {
        } catch (bytes memory err) {
            Assert.notEqual(err.length, 0, Z.E31);
        }
    }

    function checkUserResume() public {
        pxy.mem(Z.toBytes32(TIS), Z.toBytes32(0));
        itm.transferFrom(TIS, Z.AC7, 7);
        Assert.equal(itm.balanceOf(TIS), 4, Z.E33);
        Assert.equal(itm.balanceOf(Z.AC7), 5, Z.E34);
    }

    function checkContractSuspendFail() public {
        pxy.mem(Z.toBytes32(address(pxy)), Z.toBytes32(1));
        try itm.transferFrom(TIS, Z.AC7, 8) {
        } catch (bytes memory err) {
            Assert.notEqual(err.length, 0, Z.E31);
        }
    }

    function checkContractResume() public {
        pxy.mem(Z.toBytes32(address(pxy)), Z.toBytes32(0));
        itm.transferFrom(TIS, Z.AC7, 8);
        Assert.equal(itm.balanceOf(TIS), 3, Z.E35);
        Assert.equal(itm.balanceOf(Z.AC7), 6, Z.E36);
    }

    function checkBalanceFail() public {
        try itm.transferFrom(TIS, Z.AC7, 1) {
        } catch (bytes memory err) {
            Assert.notEqual(err.length, 0, Z.E31);
        }
    }

    function checkApprovalFail() public {
        try itm.approve(Z.AC7, 1) {
        } catch (bytes memory err) {
            Assert.notEqual(err.length, 0, Z.E31);
        }
    }

}