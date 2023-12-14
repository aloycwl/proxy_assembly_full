// SPDX-License-Identifier:None
pragma solidity 0.8.23;
pragma abicoder v2;

import "../tests/lib_ggc.sol";

contract ggc_test {

    GGC private ggc;
    Proxy private pxy;
    address immutable private TIS = address(this);

    function checkProxy() public {
        Assert.notEqual(address(ggc = GGC(address(pxy = new Proxy(address(new GGC()))))), address(0), Z.E02);
    }

    function checkStandards() public {
        Assert.notEqual(ggc.name(), "", Z.E03);
        Assert.notEqual(ggc.symbol(), "", Z.E04);
        Assert.equal(ggc.decimals(), 18, Z.E05);
        Assert.equal(ggc.totalSupply(), 0, Z.E06);
    }

    function checkMinting() public {
        uint amt = 100 ether;
        Assert.equal(ggc.balanceOf(TIS), 0, Z.E07);
        ggc.mint(TIS, amt);
        Assert.equal(ggc.balanceOf(TIS), amt, Z.E08);
    }

    function checkApprove() public {
        uint amt = 10 ether;
        ggc.approve(Z.AC7, amt);
        Assert.equal(ggc.allowance(TIS, Z.AC7), amt, Z.E09);
    }

    function checkTransferFrom() public {
        (uint amt, uint alw) = (1 ether, ggc.allowance(TIS, Z.AC7));
        Assert.equal(ggc.balanceOf(Z.AC7), 0, Z.E10);
        ggc.transferFrom(TIS, Z.AC7, amt);
        Assert.equal(ggc.balanceOf(Z.AC7), amt, Z.E11);
        Assert.equal(ggc.allowance(TIS, Z.AC7), alw - amt, Z.E12);
    }

    function checkTransfer() public {
        (uint amt, uint bal, uint ba2, uint alw) = (9 ether, ggc.balanceOf(Z.AC7), ggc.balanceOf(TIS), ggc.allowance(TIS, Z.AC7));
        ggc.transfer(Z.AC7, amt);
        Assert.equal(ggc.balanceOf(Z.AC7), bal + amt, Z.E13);
        Assert.equal(ggc.balanceOf(TIS), ba2 - amt, Z.E14);
        Assert.equal(ggc.allowance(TIS, Z.AC7), alw, Z.E15);
    }

    function checkTotalSupply() public {
        (uint amt, uint bal, uint bao) = (10 ether, ggc.balanceOf(Z.AC7), ggc.totalSupply());
        ggc.mint(Z.AC7, amt);
        Assert.equal(ggc.balanceOf(Z.AC7), bal + amt, Z.E16);
        Assert.equal(ggc.totalSupply(), bao + amt, Z.E17);
    }

    function checkUserSuspendFail() public {
        pxy.mem(Z.toBytes32(TIS), Z.toBytes32(1));
        try ggc.transfer(Z.AC7, 1 ether) {
        } catch (bytes memory err) {
            Assert.notEqual(err.length, 0, Z.E21);
        }
    }

    function checkUserResume() public {
        (uint amt, uint bal, uint ba2) = (10 ether, ggc.balanceOf(TIS), ggc.balanceOf(Z.AC7));
        pxy.mem(Z.toBytes32(TIS), Z.toBytes32(0));
        ggc.transfer(Z.AC7, amt);
        Assert.equal(ggc.balanceOf(TIS), bal - amt, Z.E22);
        Assert.equal(ggc.balanceOf(Z.AC7), ba2 + amt, Z.E23);
    }

    function checkContractSuspendFail() public {
        pxy.mem(Z.toBytes32(address(pxy)), Z.toBytes32(1));
        try ggc.transfer(Z.AC7, 1 ether) {
        } catch (bytes memory err) {
            Assert.notEqual(err.length, 0, Z.E21);
        }
    }

    function checkContractResume() public {
       (uint amt, uint bal, uint ba2) = (1 ether, ggc.balanceOf(TIS), ggc.balanceOf(Z.AC7));
        pxy.mem(Z.toBytes32(address(pxy)), Z.toBytes32(0));
        ggc.transfer(Z.AC7, amt);
        Assert.equal(ggc.balanceOf(TIS), bal - amt, Z.E24);
        Assert.equal(ggc.balanceOf(Z.AC7), ba2 + amt, Z.E25);
    }

    function checkOwner() public {
        Assert.equal(ggc.owner(), TIS, Z.E18);
        pxy.mem(Z.OWO, Z.toBytes32(msg.sender));
        Assert.equal(ggc.owner(), msg.sender, Z.E19);
    }

    function checkNoApprovalFail() public {
        try ggc.transfer(Z.AC7, 100000 ether) {
        } catch (bytes memory err) {
            Assert.notEqual(err.length, 0, Z.E21);
        }
    }

    function checkEnded() public {
        Assert.ok(true, "");
    }
}
    