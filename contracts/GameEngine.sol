//SPDX-License-Identifier:None
pragma solidity 0.8.20;
//被调用的接口
interface IERC20 {
    function transfer(address, uint) external returns (bool);
}
interface IDID {
    function uintData(address, uint) external view returns (uint);
    function updateUint(address, uint, uint) external; 
}
interface IProxy {
    function addrs(uint) external view returns (address);
    function setAddr(address, uint) external;
}
//置对合约的访问
contract Util {
    mapping(address => uint) public access;
    mapping(uint => address) private enumAccess;
    uint private count = 2;

    constructor(address addr1, address addr2) {
        (access[addr1], enumAccess[0], enumAccess[1]) = (access[addr2] = 999, addr1, addr2);
    }
    modifier OnlyAccess() {
        require(access[msg.sender] > 0, "Insufficient access");
        _;
    }
    //只可以管理权限币你小的人
    function setAccess(address addr, uint u) public OnlyAccess {
        unchecked{
            require(access[msg.sender] > access[addr], "Unable to modify address with higher access");
            require(access[msg.sender] > u, "Access level has to be lower than grantor");
            enumAccess[access[addr] = u] = addr;
            ++count;
        }
    }
    //获取全部受权者及他们的等级
    function getAllAccessHolders() external view returns (address[] memory addrs, uint[] memory levels){
        unchecked{
            (addrs, levels) = (new address[](count), new uint[](count));
            for (uint i=0; i<count; i++) (addrs[i], levels[i]) = (enumAccess[i], access[enumAccess[i]]);
        }
    }
}
//代理合同
contract Proxy is Util, IProxy {
    mapping (uint => address) public addrs;

    constructor(address owner) Util(owner, msg.sender) { }

    function setAddr(address addr, uint index) external OnlyAccess() {
        addrs[index] = addr;
    }
}
//游戏引擎
contract GameEngine is Util {
    IProxy private iProxy;
    uint public withdrawInterval = 60;

    constructor(address owner, address proxy) Util(owner, address(0)) {
        iProxy = IProxy(proxy);
    }
    //整数转移字符
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
    //利用签名人来哈希信息
    function withdraw(address addr, uint amt, uint8 v, bytes32 r, bytes32 s) external {
        unchecked {
            require(IDID(iProxy.addrs(2)).uintData(addr, 0) == 0, "Account is suspended");
            require(IDID(iProxy.addrs(2)).uintData(addr, 2) + withdrawInterval < block.timestamp, "Withdraw too soon");
            require(ecrecover(keccak256(abi.encodePacked(keccak256(abi.encodePacked(string.concat(
                u2s(uint(uint160(addr))), u2s(IDID(iProxy.addrs(2)).uintData(addr, 1))))))), v, r, s) 
                == iProxy.addrs(3), "Invalid signature");

            IDID(iProxy.addrs(2)).updateUint(addr, 1, IDID(iProxy.addrs(2)).uintData(addr, 1) + 1);
            IDID(iProxy.addrs(2)).updateUint(addr, 2, block.timestamp);

            IERC20(iProxy.addrs(1)).transfer(addr, amt);
        }
    }
    //管理功能
    function setWithdrawInterval(uint _withdrawInterval) external OnlyAccess {
        withdrawInterval = _withdrawInterval;
    }
}
//代币合约
contract ERC20 is Util, IERC20 {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    uint public totalSupply;
    uint8 public suspended;
    uint8 public constant decimals = 18;
    string public symbol;
    string public name;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping (address => uint)) public allowance;
    IProxy public iProxy;
    //ERC20基本函数 
    constructor(address owner, address proxy, address receiver, uint amt, 
        string memory _name, string memory _symbol) Util(owner, msg.sender) {
        (iProxy, symbol, name) = (IProxy(proxy), _symbol, _name);
        mint(amt, receiver);
    }
    function approve(address to, uint amt) external returns (bool) {
        emit Approval(msg.sender, to, allowance[msg.sender][to] = amt);
        return true;
    }
    function transfer(address to, uint amt) external returns (bool) {
        return transferFrom(msg.sender, to, amt);
    }
    function transferFrom(address from, address to, uint amt) public returns (bool) {
        unchecked {
            require(balanceOf[from] >= amt, "Insufficient balance");
            require(from == msg.sender || allowance[from][to] >= amt, "Insufficient allowance");
            require(IDID(iProxy.addrs(2)).uintData(from, 0) == 0 && 
                IDID(iProxy.addrs(2)).uintData(to, 0) == 0, "Account is suspended");
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
//储存和去中心化身份合约
contract DID is Util, IDID {
    mapping (string => address) did;
    mapping (address => mapping (uint => string)) public stringData;
    mapping (address => mapping (uint => address)) public addressData;
    mapping (address => mapping (uint => uint)) public uintData;

    modifier OnlyUnique(string calldata userName) {
        require(did[userName] == address(0), "Username existed");
        _;
    }
    constructor(address owner) Util(owner, address(this)) { }
    //谁都可以创造新用户
    function createUser(address addr, string calldata userName, string calldata name, string calldata bio) 
        external OnlyUnique(userName) {
            (did[userName], stringData[addr][0]) = (addr, userName);
            stringData[addr][1] = name;
            stringData[addr][2] = bio;
    }
    //改用户名，删除旧名来省燃料
    function changeUsername(string calldata strBefore, string calldata strAfter) external OnlyUnique(strAfter) {
        address addr = did[strBefore];
        require(msg.sender == addr, "Only owner can change user name");
        delete did[strBefore];
        updateString(did[strAfter] = addr, 0, strAfter);
    }
    //持有权限者才能更新数据
    function updateString(address addr, uint index, string calldata val) public OnlyAccess {
        stringData[addr][index] = val;
    }
    function updateAddress(address addr, uint index, address val) public OnlyAccess {
        addressData[addr][index] = val;
    }
    function updateUint(address addr, uint index, uint val) public OnlyAccess {
        uintData[addr][index] = val;
    }
}
