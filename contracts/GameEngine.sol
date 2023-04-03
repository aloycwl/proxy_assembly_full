pragma solidity 0.8.19;//SPDX-License-Identifier:None
//被调用的接口
interface IERC20 {
    function transfer(address, uint) external returns(bool);
    function setAccess(address a, bool b) external;
}
interface IGE {
    function addScore(address, uint) external;
    function withdrawal(address, uint) external;
    function score(address) external view returns (uint);
    function available(address) external view returns (uint);
    function getUpd(address) external view returns (bool);
}
interface IDB {
    function A(address, uint) external view returns (address);
    function B(address, uint) external view returns (bool);
    function U(address, uint) external view returns (uint);
    function setA(address, uint, address) external;
    function setB(address, uint, bool) external;
    function setU(address, uint, uint) external;
}
//置对合约的访问
contract Util {
    mapping(address => bool) public access;
    constructor(address a) {
        access[a] = true;
    }
    modifier OnlyAccess() {
        require(access[msg.sender], "Insufficient access");
        _;
    }
    function setAccess(address a, bool b) external OnlyAccess {
        access[a] = b;
    }
}
//代理合同
contract GameEngineProxy is Util, IGE {
    IGE public contAddr;
    constructor() Util(msg.sender) {
        contAddr = IGE(address(new GameEngine(msg.sender)));
    }
    //基本功能
    function withdrawal(address a, uint b) external {
        contAddr.withdrawal(a, b);
    }
    function score(address a) external view returns(uint){
        return contAddr.score(a);
    }
    function available(address a) external view returns(uint){
        return contAddr.available(a);
    }
    function getUpd(address a) external view returns(bool){
        return contAddr.getUpd(a);
    }
    //管理功能
    function addScore(address a, uint b) external OnlyAccess() {
        contAddr.addScore(a, b);
    }
    function setContract(address a) external OnlyAccess() {
        contAddr = IGE(a);
    }
}
//游戏引擎
contract GameEngine is Util, IGE {
    IERC20 public contAddr;
    IDB public db;
    uint public interval = 1 days;
    constructor(address a) Util(a) {
        (access[msg.sender], db) = (true, IDB(address(new DB(a))));
        contAddr = IERC20(address(new ERC20AC(a, address(db))));
    }
    //基本功能
    function withdrawal(address a, uint b) external {
        require(available(a) >= b, "Insufficient availability");
        require(!db.B(a, 0), "Account is suspended");
        unchecked {
            contAddr.transfer(a, b);
            db.setU(a, 1, available(a) - b);
        }
    }
    function score(address a) public view returns (uint) {
        return db.U(a, 0);
    }
    function available(address a) public view returns (uint) {
        return db.U(a, 1);
    }
    function getUpd(address a) public view returns (bool) {
        unchecked{
            uint u = db.U(a, 2);
            return block.timestamp > u + interval || u == 0;
        }
    }
    //管理功能
    function addScore(address a, uint b) external OnlyAccess {
        require(!db.B(a, 0), "Account is suspended");
        require(getUpd(a), "Update too frequently");
        unchecked {
            db.setU(a, 0, score(a) + b);
            db.setU(a, 1, available(a) + b);
            db.setU(a, 2, block.timestamp);
        }
    }
    function setInterval(uint a) external OnlyAccess {
        interval = a;
    }
    function setContract(address a) external OnlyAccess {
        contAddr = IERC20(a);
    }
}
//代币合约
contract ERC20AC is Util {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    bool public suspended;
    uint public totalSupply = 0;
    uint public constant decimals = 18;
    string public constant symbol = "WD";
    string public constant name = "Wild Dynasty";
    mapping(address => uint) public balanceOf;
    mapping(address => mapping (address => uint)) public allowance;
    IDB public db;
    //ERC20基本函数 
    constructor(address a, address b) Util(a) {
        (access[msg.sender], db) = (true, IDB(b));
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
            //User storage s = u[a];
            require(balanceOf[a] >= c, "Insufficient balance");
            require(a == msg.sender || allowance[a][b] >= c, "Insufficient allowance");
            require(!db.B(a, 0) && !db.B(b, 0), "Account is suspended");
            require(!suspended, "Contract is suspended");
            if (allowance[a][b] >= c) allowance[a][b] -= c;
            (balanceOf[a] -= c, balanceOf[b] += c);
            emit Transfer(a, b, c);
            return true;
        }
    }
    //管理功能
    function toggleSuspend() external OnlyAccess {
        suspended = suspended ? false : true;
    }
    function mint(uint a) public OnlyAccess {
        (totalSupply += a, balanceOf[msg.sender] += a);
        emit Transfer(address(this), msg.sender, a);
    }
    function burn(uint amt) external OnlyAccess {
        unchecked {
            require(balanceOf[msg.sender] >= amt, "Insufficient balance");
            transferFrom(msg.sender, address(0), amt);
            totalSupply -= amt;
        }
    }
}
//储存合约
//U[addr][0]=score, U[addr][1]=available, U[addr][2]=lastUpdated, B[addr][0]-blocked
contract DB is Util, IDB{
    mapping(address => mapping(uint => address)) public A;
    mapping(address => mapping(uint => bool)) public B;
    mapping(address => mapping(uint => uint)) public U;
    
    constructor(address a) Util(a) {
        access[msg.sender] = true;
    }
    function setA(address a, uint b, address c) external {
        A[a][b] = c;
    }
    function setB(address a, uint b, bool c) external {
        B[a][b] = c;
    }
    function setU(address a, uint b, uint c) external {
        U[a][b] = c;
    }
}
