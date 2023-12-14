// SPDX-License-Identifier:None
pragma solidity 0.8.23;
pragma abicoder v1;

import "../tests/lib_node.sol";

contract node_test {

    Node private nod;
    GGC private ggc;
    Item private itm;
    Proxy private pxy;
    Proxy private px2;
    Proxy private px3;
    address immutable private TIS = address(this);

    function checkProxy() public {
        ggc = GGC(address(px2 = new Proxy(address(new GGC()))));
        itm = Item(address(px3 = new Proxy(address(new Item()))));
        Assert.notEqual(address(nod = Node(address(pxy = new Proxy(address(new Node()))))), address(0), Z.E02);
    }
    
    function checkVoteAddGame() public {
        nod.createVote(TIS, 1);
        (, , , address adr) = nod.checkVoting(nod.count());
        Assert.equal(adr, msg.sender, Z.E03);
    }

    function checkVoteRemoveGame() public {
        nod.createVote(TIS, 2);
        (uint sta, , , ) = nod.checkVoting(nod.count());
        Assert.equal(sta, 2, Z.E04);
    }

    function checkVoteMassWithdrawal() public {
        nod.createVote(Z.AC7, 1e20);
        (uint sta, address adr,,) = nod.checkVoting(nod.count());
        Assert.equal(sta, 1e20, Z.E05);
        Assert.equal(adr, Z.AC7, Z.E06);
    }

    function checkCancelVote() public {
        nod.cancelVote(2);
        (uint sta , , , ) = nod.checkVoting(2);
        Assert.equal(sta, 0, Z.E07);
    }

    function checkResourceOut() public {
        ggc.mint(address(nod), 1e20);
        pxy.mem(Z.APP, Z.toBytes32(Z.ADM));
        pxy.mem(Z.TTF, Z.toBytes32(address(ggc)));
        nod.resourceOut(1e18, 27, Z.R, Z.S);
        Assert.equal(ggc.balanceOf(TIS), 1e18, Z.E08);
    }

    function checkGamesStatus() public {
        address adr = address(ggc);
        pxy.mem(Z.toBytes32(Z.toUint(adr) << 5), Z.toBytes32(1));
        Assert.ok(nod.games(adr), Z.E09);
    }

    function checkResourceIn() public {
        address adr = address(nod);
        ggc.approve(adr, 5e17);
        nod.resourceIn(address(ggc), 5e17);
        Assert.equal(ggc.balanceOf(adr), 995e17, Z.E10);
    }

    function checkNonTop5() public {
        try nod.vote(nod.count(), true) {
        } catch (bytes memory err) {
            Assert.notEqual(err.length, 0, Z.E13);
        }
    }

    function checkAddTop5() public {
        px3.mem(Z.TP5, Z.toBytes32(msg.sender));
        Assert.ok(itm.isTop5(msg.sender), Z.E11);
        pxy.mem(Z.TP5, Z.toBytes32(address(itm)));
    }

    function checkVoteAddGameFinal() public {
        nod.createVote(Z.AC7, 1);
        _mockVotes();
        Assert.ok(nod.games(Z.AC7), Z.E09);
    }

    function checkVoteIllegalFail() public {
        try nod.vote(nod.count(), true) {
        } catch (bytes memory err) {
            Assert.notEqual(err.length, 0, Z.E13);
        }
    }

    function checkVoteRemoveGameFinal() public {
        nod.createVote(Z.AC7, 2);
        _mockVotes();
        Assert.ok(!nod.games(Z.AC7), Z.E14);
    }

    function checkVoteWithdrawFinal() public {
        nod.createVote(TIS, 995e17);
        Assert.equal(ggc.balanceOf(address(nod)), 995e17, Z.E10);
        _mockVotes();
        Assert.equal(ggc.balanceOf(TIS), 1e20, Z.E15);
    }

    function _mockVotes() private {
        uint cnt = nod.count();
        pxy.mem(Z.fmtIndex(cnt, 2), Z.fmtVote(address(ggc)));
        pxy.mem(Z.fmtIndex(cnt, 3), Z.fmtVote(address(itm)));
        nod.vote(cnt, true);
        (uint sta, , ,) = nod.checkVoting(cnt);
        Assert.equal(sta, 0, Z.E12);
    }
    
}
    