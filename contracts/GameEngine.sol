pragma solidity 0.8.19;//SPDX-License-Identifier:None
//被调用的接口
interface IERC20 {
    function transfer(address, uint) external;
}
interface IGE {
    function addScore(address[] calldata, uint[] calldata) external;
    function withdrawal(address, uint) external;
    function A(address, uint) external view returns (address);
    function S(address, uint) external view returns (string memory);
    function U(address, uint) external view returns (uint);
    function setA(address, uint, address) external;
    function setS(address, uint, string calldata) external;
    function setU(address, uint, uint) external; 
}
//置对合约的访问
contract Util {
    mapping(address => bool) public access;
    constructor(address a, address b) {
        access[a] = access[b] = true;
    }
    modifier OnlyAccess() {
        require(access[msg.sender], "Insufficient access");
        _;
    }
    function setAccess(address a, bool b) public OnlyAccess {
        access[a] = b;
    }
}
//代理合同
contract GameEngineProxy is Util {
    IGE public contAddr;
    constructor() Util(msg.sender, address(this)) {
        contAddr = IGE(address(new GameEngine(msg.sender)));
    }
    //数据库功能
    function A(address a, uint b) external view returns (address) {
        return contAddr.A(a, b);
    }
    function S(address a, uint b) external view returns (string memory) {
        return contAddr.S(a, b);
    }
    function U(address a, uint b) external view returns (uint) {
        return contAddr.U(a, b);
    }
    function setA(address a, uint b, address c) external OnlyAccess {
        contAddr.setA(a, b, c);
    }
    function setS(address a, uint b, string calldata c) external OnlyAccess {
        contAddr.setS(a, b, c);
    }
    function setU(address a, uint b, uint c) external OnlyAccess {
        contAddr.setU(a, b, c);
    }
    //基本功能
    function withdrawal(address a, uint b) external {
        contAddr.withdrawal(a, b);
    }
    //管理功能
    function addScore(address[] calldata a, uint[] calldata b) external OnlyAccess() {
        contAddr.addScore(a, b);
    }
    function setContract(address a) external OnlyAccess() {
        contAddr = IGE(a);
    }
}
//游戏引擎
contract GameEngine is Util {
    IERC20 public contAddr;
    IGE public db;
    uint public interval;
    constructor(address a) Util(a, msg.sender) {
        contAddr = IERC20(address(new ERC20AC(a, address(db = IGE(address(new DB(a)))))));
    }
    //数据库功能
    function A(address a, uint b) public view returns (address) {
        return db.A(a, b);
    }
    function S(address a, uint b) public view returns (string memory) {
        return db.S(a, b);
    }
    function U(address a, uint b) public view returns (uint) {
        return db.U(a, b);
    }
    function setA(address a, uint b, address c) public OnlyAccess {
        db.setA(a, b, c);
    }
    function setS(address a, uint b, string calldata c) public OnlyAccess {
        db.setS(a, b, c);
    }
    function setU(address a, uint b, uint c) public OnlyAccess {
        db.setU(a, b, c);
    }
    //基本功能
    function withdrawal(address a, uint b) external {
        unchecked {
            require(U(a, 1) >= b, "Insufficient availability");
            require(U(a, 2) == 0, "Account is suspended");
            contAddr.transfer(a, b);
            setU(a, 1, U(a, 1) - b);
        }
    }
    //管理功能
    function addScore(address[] calldata a, uint[] calldata b) external OnlyAccess {
        unchecked {
            for (uint i; i < a.length; ++i){
                setU(a[i], 0, U(a[i], 0) + b[i]);
                setU(a[i], 1, U(a[i], 1) + b[i]);
            }
        }
    }
    function setContract(address a) external OnlyAccess {
        contAddr = IERC20(a);
    }
}
//代币合约
contract ERC20AC is Util {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    uint public totalSupply;
    uint8 public suspended;
    uint8 public constant decimals = 18;
    string public constant symbol = "WD";
    string public constant name = "Wild Dynasty";
    mapping(address => uint) public balanceOf;
    mapping(address => mapping (address => uint)) public allowance;
    IGE public db;
    //ERC20基本函数 
    constructor(address a, address b) Util(a, msg.sender) {
        db = IGE(b);
        mint(1e24);
    }
    function approve(address a, uint b) external returns(bool) {
        emit Approval(msg.sender, a, allowance[msg.sender][a] = b);
        return true;
    }
    function transfer(address a, uint b) external returns(bool) {
        return transferFrom(msg.sender, a, b);
    }
    function transferFrom(address a, address b, uint c) public returns(bool) {
        unchecked {
            require(balanceOf[a] >= c, "Insufficient balance");
            require(a == msg.sender || allowance[a][b] >= c, "Insufficient allowance");
            require(db.U(a, 2) == 0 && db.U(b, 2) == 0, "Account is suspended");
            require(suspended == 0, "Contract is suspended");
            if (allowance[a][b] >= c) allowance[a][b] -= c;
            (balanceOf[a] -= c, balanceOf[b] += c);
            emit Transfer(a, b, c);
            return true;
        }
    }
    //管理功能
    function toggleSuspend() external OnlyAccess {
        suspended = suspended == 0 ? 1 : 0;
    }
    function mint(uint a) public OnlyAccess {
        unchecked {
            (totalSupply += a, balanceOf[msg.sender] += a);
            emit Transfer(address(this), msg.sender, a);
        }
    }
    function burn(uint a) external OnlyAccess {
        unchecked {
            require(balanceOf[msg.sender] >= a, "Insufficient balance");
            transferFrom(msg.sender, address(0), a);
            totalSupply -= a;
        }
    }
}
//储存合约
//U[addr][0]=score, U[addr][1]=available, U[addr][2]=blocked
contract DB is Util {
    mapping(address => mapping(uint => address)) public A;
    mapping(address => mapping(uint => string)) public S;
    mapping(address => mapping(uint => uint)) public U;
    constructor(address a) Util(a, msg.sender) { }
    function setA(address a, uint b, address c) external OnlyAccess {
        A[a][b] = c;
    }
    function setS(address a, uint b, string calldata c) external OnlyAccess {
        S[a][b] = c;
    }
    function setU(address a, uint b, uint c) external OnlyAccess {
        U[a][b] = c;
    }
}
