pragma solidity ^0.5.12;

import "./ownable.sol";
import "./safemath.sol";

contract ZombieFactory is Ownable {
    using SafeMath for uint256;
    
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint public cooldownTime = 1 days;
    uint public zombiePrice = 0.01 ether;
    uint public zombieCount = 0;
    
    //僵尸的结构体
    struct Zombie{
        //一、uint16和unit32要分开写，不要掺杂在一块，不然的话会浪费空间，多余的浪费gas费。
        //二、写成uint16或者unit32不要省略的写成unit，unit编译器会直接看成unit256，这样会占用空间
        string name;
        uint dna;
        uint16 winCount;
        uint16 lossCount;
        uint32 level;
        uint32 readyTime;
    }
    
    Zombie[] public zombies;
    
    //映射
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;
    mapping (uint => uint) public zombieFeedTimes;
    
    event NewZombie(uint zombieId, string name, uint dna);
    
    //通过名字和时间戳随机创建僵尸的DNA
    //私有函数，函数名加下划线
    //View关键字表示只读，不用花gas
    function _generateRandomDna(string memory _str) private view returns(uint){
        return uint(keccak256(abi.encodePacked(_str,now))) % dnaModulus;//对随机数取余，确保DNA为16位
        //now是挖出区块时的时间戳，因为有规律可循所以用这种方法得到的随机数不太安全，不建议使用。
    }
    
    //Internal也是私有函数，表示可以被继承自本合约的子合约所调用；private只能在本合约内部调用
    function _createZombie(string memory _name, uint _dna) internal {
        //用结构体创建一个僵尸，数组添加僵尸元素（push），push的返回值是数组的元素个数，数组元素个数-1得到元素的序号
        uint id = zombies.push(Zombie(_name,_dna,0,0,1,0)) - 1;
        zombieToOwner[id] = msg.sender;
        //在solidity里面使用++，有可能会溢出，在此使用safemath的add
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        zombieCount = zombieCount.add(1);
        
        //当有新僵尸产生，通知NewZombie事件
        emit NewZombie(id, _name, _dna);
    }
    
    //创建僵尸
    function creatZombie(string memory _name) public {//这个参数string 后面要加memory，不然会报错
        //确定发送者没有一只僵尸
        require(ownerZombieCount[msg.sender]==0);//Require里的表达式要是为真，程序就会继续运行，为假的话，程序就会退出。
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 10;
        _createZombie(_name, randDna);
    }
    
    //Payable表示可以付费
    function buyZombie(string memory _name) public payable {
        require(ownerZombieCount[msg.sender]>0);
        require(msg.value >= zombiePrice);//Value发送者发送给这个合约多少钱
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 10 + 1;
        _createZombie(_name, randDna);
    }
    
    //external无法被内部调用，只能被外部调用
    //onlyOwner关键字来自ownable，确保此函数的调用者只能是此合约的拥有者
    function setZombiePrice(uint _price)external onlyOwner {
        zombiePrice = _price;
    }
    
}