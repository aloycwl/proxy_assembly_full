// SPDX-License-Identifier:None
pragma solidity 0.8.23;
pragma abicoder v2;

import "../tests/lib_item.sol";

contract item2_test {
    Item private itm;
    GGC private ggc;
    Proxy private pxy;
    Proxy private px2;
    address immutable TIS = address(this);

    function checkProxy() public {
        ggc = GGC(address(px2 = new Proxy(address(new GGC()))));
        Assert.notEqual(address(itm = Item(address(pxy = new Proxy(address(new Item()))))), address(0), Z.E02);
    }

    function checkSetList() public {
        bytes32 amt = Z.toBytes32(7 ether);
        pxy.mem(Z.APP, Z.toBytes32(Z.ADM)); // signer
        pxy.mem(Z.AFA, Z.toBytes32(address(ggc)));
        pxy.mem(Z.AF2, amt);
        Assert.equal(pxy.mem(Z.AF2), amt, Z.E38);
    }

    function checkTokenMintFail() public {
        string[] memory str = new string[](1);
        str[0] = Z.STR;
        try itm.mint(1, str, 28, Z.R2, Z.S2) {
        } catch (bytes memory err) {
            Assert.notEqual(err.length, 0, Z.E31);
        }
    }

    function checkTokenMint() public {
        _mint(7 ether);
    }

    // test script can't send ether
    // receive() external payable { }

    // test coin insufficient

    // function checkCoinMint() public payable {
    //     (uint amt, uint bal, string[] memory str) = (7 ether, itm.balanceOf(TIS), new string[](1));
    //     str[0] = Z.STR;
    //     Z.resetCounter(pxy);
    //     pxy.mem(Z.AFA, Z.toBytes32(1));
    //     pxy.mem(Z.AF2, Z.toBytes32(amt));
    //     payable(this).transfer(amt);
    //     itm.mint{value: amt}(1, str, 28, Z.R2, Z.S2);
    //     Assert.equal(itm.balanceOf(TIS), ++bal, Z.E37);
    // }

    function checkTokenMintFee() public {
        Z.resetCounter(pxy);
        pxy.mem(Z.TFM, Z.toBytes32(3000)); // setFee
        _mint(7 ether);
    }

    function _mint(uint amt) private {
        (uint bal, uint ba2, string[] memory str) = (itm.balanceOf(TIS), ggc.balanceOf(TIS), new string[](1));
        str[0] = Z.STR;
        ggc.mint(TIS, amt);
        ggc.approve(address(itm), amt);
        itm.mint(1, str, 28, Z.R2, Z.S2);
        Assert.equal(ggc.balanceOf(TIS), ba2 + amt, Z.E37);
        Assert.equal(itm.balanceOf(TIS), ++bal, Z.E38);
    }

}