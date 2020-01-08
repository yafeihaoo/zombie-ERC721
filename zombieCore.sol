pragma solidity ^0.5.12;

import "./zombieMarket.sol";
import "./zombieFeeding.sol";
import "./zombieAttack.sol";

contract ZombieCore is ZombieMarket,ZombieAttack,ZombieFeeding {
    
    string public constant name = "MyCryptoZombie";//constant表示不可更改
    string public constant symbol = "MCZ";
    
    //空函数，打钱又不调用合约里面的函数时，会调用这个函数
    function() external payable {
    }
    
    //提款函数，只有合约拥有者可以调用
    function withdraw() external onlyOwner {
        //this 表示当前合约的地址的指针，address(this).balance的意思是，当前合约里的余额
        owner.transfer(address(this).balance);
    }
    
    function checkBalance()external view onlyOwner returns(uint) {
        return address(this).balance;
    }
    
    
}