pragma solidity 0.8.19;//SPDX-License-Identifier:None
//被调用的接口
interface IERC20 {
    function transfer(address, uint) external returns(bool);
}
interface GE {
    function addScore(address, uint) external;
    function withdrawal(address, uint) external;
    function score(address) external view returns(uint);
    function available(address) external view returns(uint);
}
// 设置对合约的访问
contract Util {
    constructor(address a) {
        access[a] = true;
    }
    mapping(address => bool) public access;
    modifier OnlyAccess() {
        require(access[msg.sender], "Insufficient access");
        _;
    }
    function setAccess(address a, bool b) external OnlyAccess {
        access[a] = b;
    }
}
// 代理合同
contract GameEngineProxy is GE, Util {
    GE public contAddr;
    constructor() Util(msg.sender) {
        contAddr = GE(address(new GameEngine(msg.sender)));
    }
    function addScore(address a, uint b) external OnlyAccess() {
        contAddr.addScore(a, b);
    }
    function withdrawal(address a, uint b) external {
        contAddr.withdrawal(a, b);
    }
    function updateContract(address a) external OnlyAccess() {
        contAddr = GE(a);
    }
    function score(address a) external view returns(uint b){
        return contAddr.score(a);
    }
    function available(address a) external view returns(uint b){
        return contAddr.available(a);
    }
}
//游戏引擎
contract GameEngine is GE, Util {
    IERC20 public contAddr;
    mapping(address=>uint) public score;
    mapping(address=>uint) public available;

    constructor(address a) Util(a) {
        contAddr = IERC20(address(new ERC20AC()));
        access[msg.sender] = true;
    }
    // 基本功能
    function withdrawal(address a, uint b) external {
        unchecked {
            require(available[a] >= b);
            contAddr.transfer(a, b);
            available[a] -= b;
        }
    }
    // 管理功能
    function addScore(address a, uint b) external OnlyAccess {
        unchecked {
            (score[a] += b, available[a] += b);
        }
    }
    function updateContract(address a) external OnlyAccess {
        contAddr = IERC20(a);
    }
}
//代币合约
struct User {
    uint bal;
    mapping(address => uint) allow;
    bool blocked;
}
contract ERC20AC is Util {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    bool public suspended;
    uint public totalSupply = 1e24;
    uint public constant decimals = 18;
    string public constant symbol = "WD";
    string public constant name = "Wild Dynasty";
    mapping(address => User) public u;
    // ERC20基本函数 
    constructor() Util(msg.sender) {
        emit Transfer(address(this), msg.sender, u[msg.sender].bal = totalSupply);
    }
    function balanceOf(address addr) external view returns(uint) {
        require(!u[addr].blocked, "Suspended");
        return u[addr].bal;
    }
    function allowance(address addr_a, address addr_b) external view returns(uint) {
        return u[addr_a].allow[addr_b];
    }
    function approve(address a, uint b) external returns(bool) {
        u[msg.sender].allow[a] = b;
        emit Approval(msg.sender, a, b);
        return true;
    }
    function transfer(address a, uint b) external returns(bool) {
        return transferFrom(msg.sender, a, b);
    }
    function transferFrom(address a, address b, uint c) public returns(bool) {
        unchecked {
            User storage s = u[a];
            require(s.bal >= c, "Insufficient balance");
            require(a == msg.sender || s.allow[b] >= c, "Insufficient allowance");
            require(!suspended && !s.blocked, "Suspended");
            if (s.allow[b] >= c) s.allow[b] -= c;
            (s.bal -= c, u[b].bal += c);
            emit Transfer(a, b, c);
            return true;
        }
    }
    // 自定义函数
    function toggleSuspend() external OnlyAccess {
        suspended = suspended ? false : true;
    }
    function toggleBlock(address addr) external OnlyAccess {
        u[addr].blocked = !u[addr].blocked;
    }
    function burn(uint amt) external OnlyAccess {
        unchecked {
            require(u[msg.sender].bal >= amt, "Insufficient balance");
            transferFrom(msg.sender, address(0), amt);
            totalSupply -= amt;
        }
    }
}
