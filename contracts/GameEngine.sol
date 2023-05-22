pragma solidity 0.8.20;//SPDX-License-Identifier:None
//被调用的接口
interface IERC20 {
    function transfer(address, uint) external;
}
interface IGameEngine {
    function withdraw(address, uint, uint8, bytes32, bytes32) external;
    function U(address, uint) external view returns (uint);
    function setU(address, uint, uint) external; 
}
//置对合约的访问
contract Util {
    mapping(address => uint) public access;

    constructor(address addr1, address addr2) {
        access[addr1] = access[addr2] = 999;
    }
    modifier OnlyAccess() {
        require(access[msg.sender] > 0, "Insufficient access");
        _;
    }
    function setAccess(address addr, uint u) public OnlyAccess {
        require(access[msg.sender] > access[addr], "Unable to modify address with higher access");
        require(access[msg.sender] > u, "Access level has to be lower than grantor");
        access[addr] = u;
    }
}
//代理合同
contract GameEngineProxy is Util {
    IGameEngine public contAddr;

    constructor(string memory _name, string memory _symbol) Util(msg.sender, address(this)) {
        contAddr = IGameEngine(address(new GameEngine(msg.sender, _name, _symbol)));
    }
    //数据库功能
    function U(address addr, uint index) external view returns (uint) {
        return contAddr.U(addr, index);
    }
    //管理功能
    function withdraw(uint amt, uint8 v, bytes32 r, bytes32 s) external {
        contAddr.withdraw(msg.sender, amt, v, r, s);
    }
    function setContract(address addr) external OnlyAccess() {
        contAddr = IGameEngine(addr);
    }
}
//游戏引擎
contract GameEngine is Util {
    IERC20 public contAddr;
    IGameEngine public db;
    address public signer;
    uint public withdrawInterval = 60;

    constructor(address addr, string memory _name, string memory _symbol) Util(addr, msg.sender) {
        (contAddr, signer) = 
            (IERC20(address(new ERC20(addr, address(db = IGameEngine(address(new DB(addr)))), _name, _symbol))), addr);
    }
    //数据库功能
    function U(address addr, uint index) public view returns (uint) {
        return db.U(addr, index);
    }
    function u2s(uint num) private pure returns (string memory) {
        unchecked{
            if (num == 0) return "0";
            uint j = num;
            uint l;
            while (j != 0) (++l, j /= 10);
            bytes memory bstr = new bytes(l);
            j = num;
            while (j != 0) (bstr[--l] = bytes1(uint8(48 + j % 10)), j /= 10);
            return string(bstr);
        }
    }
    function withdraw(address addr, uint amt, uint8 v, bytes32 r, bytes32 s) external {
        unchecked {
            require(U(addr, 0) == 0, "Account is suspended");
            require(U(addr, 2) + withdrawInterval < block.timestamp, "Withdraw too soon");
            require(ecrecover(keccak256(abi.encodePacked(keccak256(abi.encodePacked(string.concat(
                u2s(uint(uint160(addr))), u2s(U(addr, 1))))))), v, r, s) == signer, "Invalid signature");
            db.setU(addr, 1, U(addr, 1) + 1);
            db.setU(addr, 2, block.timestamp);
            contAddr.transfer(addr, amt);
        }
    }
    //管理功能
    function setContract(address addr) external OnlyAccess {
        contAddr = IERC20(addr);
    }
    function setSigner(address addr) external OnlyAccess {
        signer = addr;
    }
    function setWithdrawInterval(uint _withdrawInterval) external OnlyAccess {
        withdrawInterval = _withdrawInterval;
    }
}
//代币合约
contract ERC20 is Util {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    uint public totalSupply;
    uint8 public suspended;
    uint8 public constant decimals = 18;
    string public symbol;
    string public name;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping (address => uint)) public allowance;
    IGameEngine public db;
    //ERC20基本函数 
    constructor(address addr1, address addr2, string memory _name, string memory _symbol) Util(addr1, msg.sender) {
        (db, symbol, name) = (IGameEngine(addr2), _symbol, _name);
        mint(1e24, msg.sender);
    }
    function approve(address to, uint amt) external returns(bool) {
        emit Approval(msg.sender, to, allowance[msg.sender][to] = amt);
        return true;
    }
    function transfer(address to, uint amt) external returns(bool) {
        return transferFrom(msg.sender, to, amt);
    }
    function transferFrom(address from, address to, uint amt) public returns(bool) {
        unchecked {
            require(balanceOf[from] >= amt, "Insufficient balance");
            require(from == msg.sender || allowance[from][to] >= amt, "Insufficient allowance");
            require(db.U(from, 0) == 0 && db.U(to, 0) == 0, "Account is suspended");
            require(suspended == 0, "Contract is suspended");
            if (allowance[from][to] >= amt) allowance[from][to] -= amt;
            (balanceOf[from] -= amt, balanceOf[to] += amt);
            emit Transfer(from, to, amt);
            return true;
        }
    }
    //管理功能
    function toggleSuspend() external OnlyAccess {
        suspended = suspended == 0 ? 1 : 0;
    }
    function mint(uint amt, address addr) public OnlyAccess {
        unchecked {
            (totalSupply += amt, balanceOf[addr] += amt);
            emit Transfer(address(this), addr, amt);
        }
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
//U[addr][0]=blocked, U[addr][1]=counter, U[addr][2]=timestamp
contract DB is Util {
    mapping(address => mapping(uint => uint)) public U;
    constructor(address addr) Util(addr, msg.sender) { }
    function setU(address addr, uint index, uint amt) external OnlyAccess {
        U[addr][index] = amt;
    }
}

//migrate this out...
