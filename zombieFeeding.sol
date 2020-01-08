pragma solidity ^0.5.12;

import "./zombieHelper.sol";

contract ZombieFeeding is ZombieHelper {
    
    function feed(uint _zombieId) public onlyOwnerOf(_zombieId) {
        //存储范围是storage，代表也把指针传递给了myZombie，修改了myZombie的内容，会改变zombies里对应的内容
        Zombie storage myZombie = zombies[_zombieId];
        require(_isReady(myZombie));
        zombieFeedTimes[_zombieId] = zombieFeedTimes[_zombieId].add(1);
        _triggerCooldown(myZombie);
        if(zombieFeedTimes[_zombieId] % 10 == 0) {
            uint newDna = myZombie.dna - myZombie.dna % 10 + 8;
            _createZombie("zombie's son", newDna);
        }
    }
    
    
}